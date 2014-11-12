var
	global_pallette

mob
	proc
		getColor(command_name,the_color)
			the_color = lowertext(the_color)
			if(!is_hex(the_color)) CRASH("Invalid hex value: [the_color]")
			var/r=hex2rgb(the_color)[1]
			var/g=hex2rgb(the_color)[2]
			var/b=hex2rgb(the_color)[3]
			if(!global_pallette)
				var/palette={"<span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; border-top: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span>"}
				var/scriptAll={"font-size: 1px; cursor: crosshair; height: 16px;"}
				for(var/R=0,R<=255,R+=5)
					palette+={"<span onMouseDown="mouse_down('red','[R]');" onMouseUp="mouse_up();" onMouseOver="set_color('red','[R]');" id="red=[R]" style="border-bottom: 1px solid black; border-top: 1px solid black; background-color: rgb([R],0,0); [scriptAll]">&nbsp;&nbsp;&nbsp;&nbsp;</span>"}
				palette+={"<span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; border-top: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span><br /><span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span>"}
				for(var/G=0,G<=255,G+=5)
					palette+={"<span onMouseDown="mouse_down('green','[G]');" onMouseUp="mouse_up();" onMouseOver="set_color('green','[G]');" id="green=[G]" style="border-bottom: 1px solid black; background-color: rgb(0,[G],0); [scriptAll]">&nbsp;&nbsp;&nbsp;&nbsp;</span>"}
				palette+={"<span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span><br /><span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span>"}
				for(var/B=0,B<=255,B+=5)
					palette+={"<span onMouseDown="mouse_down('blue','[B]');" onMouseUp="mouse_up();" onMouseOver="set_color('blue','[B]');" id="blue=[B]" style="border-bottom: 1px solid black; background-color: rgb(0,0,[B]); [scriptAll]">&nbsp;&nbsp;&nbsp;&nbsp;</span>"}
				palette+={"<span style="font-size: 1px; height: 16px; border-bottom: 1px solid black; background-color: rgb(0,0,0);">&nbsp;</span><br />"}
				global_pallette=palette
			var/display={"
<html>
<head>
<title>[replace_text(command_name, "_", " ")]</title>

<script language="javascript" type="text/javascript">

var old_id_r;
var old_id_g;
var old_id_b;
var old_r;
var old_g;
var old_b;
var shift=0;

window.onload = function()
	{
		setRed([r]);
		setGreen([g]);
		setBlue([b]);
		document.onselectstart = function () { return false; } // ie
		document.onmousedown = function () { return false; } // mozilla
	}

function mouse_down(color,the_elem)
	{
		shift=color;

		if(shift=="red") setRed(the_elem);
		if(shift=="green") setGreen(the_elem);
		if(shift=="blue") setBlue(the_elem);
	}
function mouse_up()
	{
		shift=0;
	}

function set_color(color,the_elem)
	{
		if(!shift)
			return null
		else
			if(shift=="red") setRed(the_elem);
			if(shift=="green") setGreen(the_elem);
			if(shift=="blue") setBlue(the_elem);
	}


function round_to(num, to)
	{
		return Math.round(num/to)*to;
	}

function numOnly(the_value)
	{
		if((the_value==0) && (window.event.keyCode==48))
			window.event.keyCode=0;
		if(window.event.keyCode<48 || window.event.keyCode>57)
			window.event.keyCode=0;
	}

function isMaxLength(the_obj)
	{
		var obj_max_len=the_obj.getAttribute ? parseInt(the_obj.getAttribute("maxlength")) : "";
		if(the_obj.getAttribute && the_obj.value.length>obj_max_len);
			the_obj.value=obj.value.substring(0,obj_max_len);
	}

function setHex(r,g,b)
	{
		var HexChars="0123456789abcdef";
		r=hexValue(r);
		g=hexValue(g);
		b=hexValue(b);
		document.colorPicker.selcolor.value=''+r+''+g+''+b+'';
	}


function convert2dec(the_hex)
	{
		if(the_hex == 0) return 0;
		else if(the_hex == 1) return 1;
		else if(the_hex == 2) return 2;
		else if(the_hex == 3) return 3;
		else if(the_hex == 4) return 4;
		else if(the_hex == 5) return 5;
		else if(the_hex == 6) return 6;
		else if(the_hex == 7) return 7;
		else if(the_hex == 8) return 8;
		else if(the_hex == 9) return 9;
		else if(the_hex == "a") return 10;
		else if(the_hex == "b") return 11;
		else if(the_hex == "c") return 12;
		else if(the_hex == "d") return 13;
		else if(the_hex == "e") return 14;
		else if(the_hex == "f") return 15;
		else return 0;
	}

function HexToDec(the_elem)
	{
		if(the_elem.length != 6)
			return;
		else
			the_elem=the_elem.toLowerCase();
			a=convert2dec(the_elem.substring(0, 1));
			b=convert2dec(the_elem.substring(1, 2));
			c=convert2dec(the_elem.substring(2, 3));
			d=convert2dec(the_elem.substring(3, 4));
			e=convert2dec(the_elem.substring(4, 5));
			f=convert2dec(the_elem.substring(5, 6));
			r=(a*16)+b;
			g=(c*16)+d;
			b=(e*16)+f;
			setRed(r);
			setGreen(g);
			setBlue(b);
	}

function hexValue(the_decimal)
	{
		var HexChars="0123456789abcdef";
		return HexChars.charAt((the_decimal>>4)&0xf)+HexChars.charAt(the_decimal&0xf);
	}

function correctElem(the_elem)
	{
		if(!the_elem) the_elem="0";
		if(the_elem > 255) the_elem="255";
		if(the_elem < 0) the_elem="0";
		if(the_elem > 0) the_elem=Math.abs(the_elem);
		return the_elem;
	}

function setRed(the_elem)
	{
		the_elem=correctElem(the_elem);
		if(old_r && old_id_r) document.getElementById(old_id_r).style.background='rgb('+old_r+',0,0)';
		document.colorPicker.R.value=the_elem;
		setHex(document.colorPicker.R.value,document.colorPicker.G.value,document.colorPicker.B.value);
		document.getElementById('red='+round_to(the_elem, 5)).style.background="#FFF";
		old_id_r='red='+round_to(the_elem, 5);
		old_r=the_elem;
		document.colorPicker.selcolor.style.backgroundColor='rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
		document.colorPicker.selcolor.style.border='2px outset rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
	}

function setGreen(the_elem)
	{
		the_elem=correctElem(the_elem);
		if(old_g && old_id_g) document.getElementById(old_id_g).style.background='rgb(0,'+old_g+',0)';
		document.colorPicker.G.value=the_elem;
		setHex(document.colorPicker.R.value,document.colorPicker.G.value,document.colorPicker.B.value);
		document.getElementById('green='+round_to(the_elem, 5)).style.background="#FFF";
		old_id_g='green='+round_to(the_elem, 5);
		old_g=the_elem;
		document.colorPicker.selcolor.style.backgroundColor='rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
		document.colorPicker.selcolor.style.border='2px outset rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
	}

function setBlue(the_elem)
	{
		the_elem=correctElem(the_elem);
		if(old_b && old_id_b) document.getElementById(old_id_b).style.background='rgb(0,0,'+old_b+')';
		document.colorPicker.B.value=the_elem;
		setHex(document.colorPicker.R.value,document.colorPicker.G.value,document.colorPicker.B.value);
		document.getElementById('blue='+round_to(the_elem, 5)).style.background="#FFF";
		old_id_b='blue='+round_to(the_elem, 5);
		old_b=the_elem;
		document.colorPicker.selcolor.style.backgroundColor='rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
		document.colorPicker.selcolor.style.border='2px outset rgb('+document.colorPicker.R.value+','+document.colorPicker.G.value+','+document.colorPicker.B.value+')';
	}

function submitColor()
	{
		var theR=document.colorPicker.R.value;
		var theG=document.colorPicker.G.value;
		var theB=document.colorPicker.B.value;
		window.location.href="byond://?src=\ref[src];command=[command_name]&r="+theR+"&g="+theG+"&b="+theB;
	}

</script>
<body>
[css]

</head>

<body onMouseUp="mouse_up();">
<form name="colorPicker">
<center>[global_pallette]</center><br><center>
<input type="text" maxlength="6" onKeyUp="HexToDec(this.value);" style="font-weight: bold; color: white; text-align: center;vertical-align: middle;" name="selcolor" size="20" class="hexfield" /><br />
<input type="text" maxlength="3" style="border: 2px outset red; font-weight: bold; color: white; text-align: center; vertical-align: middle; background-color: red;" name="R" value="0" size="3" class="R" onKeyPress="numOnly(this.value);" onBlur="setRed(this.value);" />
<input type="text" maxlength="3" style="border: 2px outset green; font-weight: bold; color: white; text-align: center; vertical-align: middle; background-color: green;" name="G" value="0" size="3" class="G" onKeyPress="numOnly(this.value);" onBlur="setGreen(this.value);" />
<input type="text" maxlength="3" style="border: 2px outset blue; font-weight: bold; color: white; text-align: center; vertical-align: middle; background-color: blue;" name="B" value="0" size="3" class="B" onKeyPress="numOnly(this.value);" onBlur="setBlue(this.value);" />
<br><br><input type="button" value="Apply Color" onClick="submitColor();" class="button"></center></form></body>
"}
			src<<browse(display,"size=270x180,window=[command_name]")

//mob/verb/namecolor()
	//src.getColor("Name_Color",src.name_color)

var/css={"

<style type='text/css'>

body{
  margin-right: 0%;
  margin-left: 7%;
  color: #000000;
  background-color: rgb(204,164,103);
  font-family:"tahoma";
  font-size: 12px;}

a:link, a:visited{
  color: #000000;
  text-decoration: none;}

a:hover {
  text-decoration: underline;}

input,textarea,select {
  background: #dddddd;
  color: #000000;
  font-size: 12px;
  font-family:"tahoma";
  border: 1px solid #999999;}

#colorselect {
  border-left: 2px ridge #c0c0c0;
  border-right: 2px ridge #c0c0c0;
  border-top: 2px ridge #c0c0c0;
  border-bottom: 2px ridge #c0c0c0;
  background-color: #bbbbbb;
  width: 100%;}

</style>

"}

/*mob

	Topic(href,data[])

		switch(data["command"])

			if("Name_Color")
				var/r=text2num(data["r"])
				var/g=text2num(data["g"])
				var/b=text2num(data["b"])
				usr.name_color=rgb(r,g,b)
				usr<<"Name: <font color=[rgb(r,g,b)]><b>[rgb(r,g,b)]</b></font>"
				usr<<browse(null,"window=Name_Color")

			if("Text_Color")
				var/r=text2num(data["r"])
				var/g=text2num(data["g"])
				var/b=text2num(data["b"])
				usr.text_color=rgb(r,g,b)
				usr<<"Text: <font color=[rgb(r,g,b)]><b>[rgb(r,g,b)]</b></font>"
				usr<<browse(null,"window=Text_Color")*/

proc
	hex2rgb(hex)
		if(!is_hex(hex)) return
		var/red=(hex_loc(copytext(hex,2,3))*16)+hex_loc(copytext(hex,3,4))
		var/green=(hex_loc(copytext(hex,4,5))*16)+hex_loc(copytext(hex,5,6))
		var/blue=(hex_loc(copytext(hex,6,7))*16)+hex_loc(copytext(hex,7,8))
		return list(red,green,blue)

	hex_loc(char)
		var/list/hex_vals=list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
		return hex_vals.Find(lowertext(char))-1

	is_hex(string)
		var/list/hex_vals=list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
		if(text2ascii(string,1)!=35 || length(string)!=7) return 0
		for(var/i=2,i<=length(string),i++) if(!hex_vals.Find(copytext(string,i,i+1))) return 0
		return 1

	replace_text(haystack, needle, replace)
		var/findLen=length(needle)
		var/replaceLen=length(replace)
		var/pos
		var/offset
		offset=1
		while(1)
			pos=findtext(haystack,needle,offset)
			if(!pos) break;
			haystack=copytext(haystack,1,pos)+replace+copytext(haystack,pos+findLen)
			offset=pos+replaceLen
		return haystack