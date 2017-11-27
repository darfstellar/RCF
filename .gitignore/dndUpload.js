/*
	dndUpload.js
	
	Does the stuff for drag-and-drop file upload using a normal form. Combined with the styles in dndUpload.css (change as needed)
	this app manages a dropzone that will process files dropped upon it, or if clicked upon the hidden input of type=file will open
	a file browser box to select files.
	
	Once files are selected the file contents are base64-encoded and stuffed into a form field, plus an info <div> is displayed
	with information about the selected files. On form submit, the form fields containing file contents are uploaded. The back end
	process must break the comma-delimted file information to get the filename and contents. The contents have to be unencoded to
	return them to their original state.
	
	Supported HTML containers for various things:

	'dropzone' is the workhorse that does the work, like so (dropzoneName = 'dropzone') - 	
		<div id="dropzone" class=dznormal ondrop="drop_handler(event);" ondragover="dragover_handler(event);" 
		ondragenter="dragenter_handler(event);" ondragleave="dragleave_handler(event);"
		onClick="dropzone_click_handler()"><br>Drop file(s) here<br>or<br>click to browse</div>
	
	If you want to display informational/error messages, put this div somewhere appropriate (consoleContainerName = 'console') -
		<div id=console></div>
	
	Create a form with onSubmit=submit_handler() if you want to check the number of files being uploaded (maxFiles = 4) and display a 
	countdown timer for impatient types (secondsToWait = 60).
		<form action="myprogram.cfm" method=post enctype="multipart/form-data" onSubmit="return submit_handler();">
	
	Create form fields for the number of files you intend to accept (maxFiles = 4) (fileDataContainerPrefix = 'filedata') -
		<input type=hidden name=filedata1 id=filedata1>
		<input type=hidden name=filedata2 id=filedata2>
		<input type=hidden name=filedata3 id=filedata3>
		<input type=hidden name=filedata4 id=filedata4>

	Create a type=file field to handle file browsing (fileInputName = 'myfiles') -
		<input type=file name=myfiles id=myfiles multiple accept=".csv,.xls" class="invis" onChange="onchange_handler(event);">

	Then create file info divs, one for each file data field you created above (fileInfoContainerPrefix = 'fileinfo') -
		<div id="fileinfo1" class="invis"></div>
		<div id="fileinfo2" class="invis"></div>
		<div id="fileinfo3" class="invis"></div>
		<div id="fileinfo4" class="invis"></div>
		
	Add links to the dndUpload.js and dndUpload.css files and things should start to work. Change styles as desired, etc.
*/

// variables that can be set per application
var debugging = false; // displays various informative items to the console.log, or not, your choice
var maxFiles = 1; // this is all I can take, I can't take no more!
var secondsToWait = 10; // seconds to display for countdown timer
var acceptedExtensions = ['pdf']; // file extensions I'll accept
var acceptedTypes = ['application/pdf']; // javascript MIME types I'll accept
var dropzoneName = 'dropzone'; // name for the dropzone container
var containerName = 'wrapper'; // name of the div to expand/contract for esthetic purposes when exposing file info boxes
var fileInputName = 'myfiles'; // name of the input type=file field to capture the click on dropzone
var containerBottomMarginNormal = '15px'; // bottom container margin with no file info box(es) exposed
var containerBottomMarginExpanded = '120px'; // bottom container margin needed for file info box(es)
var consoleContainerName = 'console'; // console for messages
var fileDataContainerPrefix = 'filedata'; // form field prefix for file data
var fileInfoContainerPrefix = 'fileinfo'; // file info boxes to show user what files are being uploaded
var removeLinkClass = 'consoleremove remove'; // class for the 'remove' link in info boxes

// roll your own settings for any of the variables above
function uploadInit(stuff)
{
	if (stuff)
	{
		var fields = ['debugging','maxFiles','secondsToWait','acceptedExtensions','acceptedTypes','dropzoneName',
			'containerName','fileInputName','containerBottomMarginNormal','containerBottomMarginExpanded',
			'consoleContainerName','fileDataContainerPrefix','fileInfoContainerPrefix','removeLinkClass'];
		
		for (var i=0; i < fields.length; i++)
		{
			if (stuff[fields[i]]) 
			{
				window[fields[i]] = stuff[fields[i]];
				if (debugging) console.log('Setting '+fields[i]+' to '+stuff[fields[i]]);
			}
		}
	}
}

// internal variables
var seconds=1, intervalID; // stuff for the countdown timer
var filesSelected = 0; // counts how many files are selected for processing

// on form submit, count the files being uploaded and then start a countdown timer
function submit_handler()
{
	if (filesSelected != maxFiles) 
	{
		setConsoleText('You must select '+maxFiles+' files for upload.');
		return false;
	}
	else 
	{
		showStatus();
		return true;
	}
}

// shows a countdown timer to prevent impatience
function showStatus()
{
	if (secondsToWait > 0)
	{
		setConsoleText('Working... Give me '+secondsToWait+' seconds or so.<div name=seconds id=seconds></div>');
		// assign the 'seconds' class to the 'seconds' div (you did create the class, didn't you?)
		$('#seconds').attr("class","seconds");
		// fire off the countdown timer
		counter();
	}
}

// keeps a count of seconds up to secondsToWait and then gets embarrassed and quits
function counter()
{
	intervalID = setInterval(
		function()
		{ 
			if (seconds > secondsToWait) 
			{
				clearInterval(intervalID); 
				setConsoleText('Well this is embarrassing. I\'ll go check on it.');
			} 
			else 
				document.getElementById('seconds').innerHTML=seconds++;
		}
		, 1000);
}

// for the 'input type=file' element to get the selected file(s)s
function onchange_handler(ev)
{
	if (($('#'+fileInputName))[0].files.length != maxFiles) 
	{
		setConsoleText('You must select '+maxFiles+' files for upload.');
		return false;
	}
	processFiles(($('#'+fileInputName))[0].files);
}

// doesn't do much but here to turn off default behavior
function dragover_handler(ev) 
{
	ev.preventDefault();
	ev.dataTransfer.dropEffect = "move"
}

// handles the document drop process	
function drop_handler(ev) 
{
	ev.preventDefault();
	setConsoleText('');
	// turn off highlight class on dropzone
	dragleave_handler(ev);
	
	var files = ev.dataTransfer.files; // Array of all files dropped on dropzone
	
	if (files.length > maxFiles || filesSelected > maxFiles || (files.length + filesSelected) > maxFiles)
	{
		setConsoleText('Only '+maxFiles+' files can be uploaded. You have selected '+(files.length + filesSelected)+'.');
		return false;
	}
	
	processFiles(files);
}

// do what we do with the file contents
function processFiles(files)
{
	// process each file passed in
	for (var i=0, file; file=files[i]; i++) 
	{
		// check the file MIME type (as seen by javascript, not necessarily the same as the browser) and file extension
		var ext = file.name.split('.').pop();
		if ($.inArray(file.type, acceptedTypes) != -1 && $.inArray(ext, acceptedExtensions) != -1)
		{
			// FileReader is asynchronous so can't rely on file order, number the files as they are read
			var reader = new FileReader();
			reader.onload = (function(file) 
				{
					return function(e) 
					{
						// increment the number of files read. This is the form field identifier for data storage
						filesSelected++;
						// write the file contents into a form field. Prefix the contents with the filename from which the contents came
						/* Note: the result of readAsDataURL() is a string: the MIME type, comma, base64-encoded file contents. I prepend the
							filename as another field using a comma delimiter as well, then the backend program breaks the contents on
							commas and has all the needed parts
						*/
						if (debugging) console.log('File '+filesSelected+': '+file.name);
						setFile(filesSelected, file.name+','+(e.target.result));
	
						// create a link to remove a file, along with file information, and stuff it into a console div
						var output = 'File <a class="'+removeLinkClass+'" href="javascript:;" onclick="removeMe(this.parentNode.id)">[Remove]</a>:';
						output += '<br>- Name: ' + file.name + '<br>- Size: ' + file.size + '<br>- Modified: ';
						output += (file.lastModifiedDate ? file.lastModifiedDate.toLocaleDateString() : 'n/a');
						setFileInfoText(filesSelected, output);
					};
				})(file);
			reader.readAsDataURL(file);
		}
		else
		{
			setConsoleText('Only '+acceptedExtensions.join(' or ')+' files are accepted.<br>At least one document selected has the .'+ext+' extension.');
			break;
		}
	}
}

// highlights the dropzone so the user knows something is actually happening
function dragenter_handler(e) 
{
  $('#'+dropzoneName).addClass('dzover');
}

// turns off dropzone highlight and returns to normal
function dragleave_handler(e) 
{
  $('#'+dropzoneName).removeClass('dzover');
}

// if they click on the dropzone, behave like a file select control
function dropzone_click_handler()
{
	clearAllFiles();
	clearAllConsoles();
	// there is a hidden file select box, so trigger a click on it
	$('#'+fileInputName).trigger('click'); return true;
}

// output HTML to the message console
function setConsoleText(text)
{
	setContainerText(consoleContainerName, text);
}

// output HTML to the selected file information container
function setFileInfoText(which, text)
{
	if (which) setContainerPadding(containerBottomMarginExpanded);
	setContainerText(fileInfoContainerPrefix+which, text);
}

// set the value of the given container
function setContainerText(which, text)
{
	if (which)
	{
		if (text) 
		{
			$('#'+which).removeClass('invis');
			$('#'+which).addClass('vis');
		}
		else 
		{	$('#'+which).removeClass('vis');
			$('#'+which).addClass('invis');
		} 
		$('#'+which).html(text);
	
		if (debugging) console.log(which+': '+text);
	}
}

// clear all consoles and file info boxes
function clearAllConsoles()
{
	for (var i=1; i<=maxFiles; i++)
	{
		setFileInfoText(i, '');
	}
	setConsoleText('');
	filesSelected = 0;
	setContainerPadding(containerBottomMarginNormal);
}

// associates file content with the selected container
function setFile(which, val)
{
	$('#'+fileDataContainerPrefix+which).val(val);
}

// clears all file containers
function clearAllFiles()
{
	for (var i=1; i<=maxFiles; i++)
	{
		$('#'+fileDataContainerPrefix+i).val('');
	}
}

// when a user clicks to remove a file, figure out how to clean up the mess
function removeMe(which)
{
	// 'which' is the id of the console div, which will be console1, console2, etc. Slice off the number to know what set of controls to work with
	var index = Number(which.slice(-1));
	// process the file controls from the one removed to the end of the files selected
	for (var i=index; i<filesSelected; i++)
	{
		// move file names and contents from the end to the beginning
		var target = i+1;
		setFile(i, $('#'+fileDataContainerPrefix+target).val());
		setFileInfoText(i, $('#'+fileInfoContainerPrefix+target).html());
	}
	// empty the last container set since that will always need to be done
	setFile(filesSelected, '');
	setFileInfoText(filesSelected, '');
	filesSelected--;
	// make the top-level container pretty if there are no files remaining
	if (filesSelected == 0) setContainerPadding(containerBottomMarginNormal);
}

// sets the container padding depending on what's being done
function setContainerPadding(amount)
{
	if (containerName && amount)
	{
		$('#'+containerName).css('padding-bottom', amount);
	}
}
