var
	list/w_vowels = list("a","e","i","o","u")
	list/w_sentencemixing = list()
	w_max_sentences = 1500

proc
	LoadSentenceMixing()
		if(fexists("sentencemix.sav"))
			var/savefile/F = new("sentencemix.sav")
			F >> w_sentencemixing
		else
			w_sentencemixing = debug_words

	SaveSentenceMixing()
		if(fexists("sentencemix.sav")) fdel("sentencemix.sav")
		var/savefile/F = new("sentencemix.sav")
		F << w_sentencemixing
		F << chain

	CaptureTxt(str)
		var/list/s_list = SeparateSentences(str)
		for(var/sentence in s_list)
			var/list/w_list = dd_text2list(sentence," ")
			var/true_len = w_list.len
			for(var/w in w_list)
				if(length(w) < 2) true_len--
			if(true_len <= 1)
				//dbg("Sentence is too short.")
				continue
			w_sentencemixing += sentence
		if(w_sentencemixing.len > w_max_sentences)
			w_sentencemixing.Cut(rand(1,w_sentencemixing.len))
			//dbg("Sentence file trimmed.")

	ProduceSentence(sentence,log)
		var/tries = 5
		if(!sentence) sentence = pick(w_sentencemixing) //Pick a sentence.
		var/list/s_list = dd_text2list(sentence," ") //Explode it.
		for(var/w in s_list)
			if(length(w) < 2) s_list -= w
		if(!s_list.len)
			w_sentencemixing -= sentence
			return .()
		PickWord
		var/split_word = pick(s_list) //Pick a word from the sentence.

		//Get the location of the end of the word.
		var/split_loc = findtext(sentence,split_word)
		split_loc += length(split_word)

		if(log)
			dbg("Sentence: [sentence]")
			dbg("Word: \"[split_word]\" ending at [split_loc]")

		//Find all the sentences that also contain the word.
		var/list/choices = list()
		for(var/s in w_sentencemixing)
			if(findtext(s,split_word))
				choices += s

		if(log)
			dbg("Choices include:")
			for(var/s in choices)
				dbg("--[s]")

		if(!choices.len)
			//Well shit
			tries--
			if(tries) goto PickWord
			var/capital_letter = copytext(sentence,1,2)
			var/rest_of_sentence = copytext(sentence,2)
			sentence = text("[][][]",uppertext(capital_letter),rest_of_sentence,pick(prob(15); "?","!","."))
			return sentence

		//Get another sentence, split both sentences along the common word.
		sentence = copytext(sentence,1,split_loc)
		var/other_sentence = pick(choices)
		var/merge_loc = findtext(other_sentence,split_word)
		merge_loc += length(split_word)
		other_sentence = copytext(other_sentence,merge_loc)
		if(log)
			dbg("Assembly: \"[sentence]\" + \"[other_sentence]\" at [merge_loc]")

		//Stick the sentences together. Capitalize and punctuate appropriately.
		sentence = sentence + other_sentence
		if(prob(50)) return .(sentence,log)
		var/capital_letter = copytext(sentence,1,2)
		var/rest_of_sentence = copytext(sentence,2)
		sentence = text("[][][]",uppertext(capital_letter),rest_of_sentence,pick(prob(15); "?","!","."))
		if(!sentence) CRASH("No sentence at end of sentence mixing.")
		return sentence

	SeparateSentences(block)
		var/list/senlist = dd_text2list(block,".")
		for(var/i in senlist)
			var/addition = dd_text2list(i,"?")
			senlist += addition
			senlist -= i
		for(var/i in senlist)
			var/addition = dd_text2list(i,"!")
			senlist += addition
			senlist -= i
		for(var/i in senlist)
			if(!i) senlist -= i
			RemoveExtraSpaces(i)
		return senlist

mob/verb

	PrintSentences()
		text2file(dd_list2text(w_sentencemixing,"\n"),"sentencemixing.txt")
		src << "Printed to sentencemixing.txt."
	TestMixing()
		src << ProduceSentence(,1)
