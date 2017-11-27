/*
	Makes sure required fields are filled, and/or one of a set of fields is filled
*/
function validateFields(requiredFields, oneOfTheseFieldsRequired)
{
	var message = '';
		
	if (requiredFields)
	{
		for (i = 0; i < requiredFields.length; i++)
		{
			var s = document.getElementById(requiredFields[i]);
			if (s && s.value.length < 1) 
				message += '  ' + cleanUp(s.id) + "\n";
		}
	}

	if (oneOfTheseFieldsRequired)
	{
		var oneOfTheseFieldsFound = false;
		for (i = 0; i < oneOfTheseFieldsRequired.length; i++)
		{
			var s = document.getElementById(oneOfTheseFieldsRequired[i]);
			if (s && s.value.length > 0)
			{
				oneOfTheseFieldsFound = true;
				break;
			}
		}
		if (!oneOfTheseFieldsFound) 
		{
			message += '  One of: ';
			for (i = 0; i < oneOfTheseFieldsRequired.length; i++) 
			{
				var s = document.getElementById(oneOfTheseFieldsRequired[i]);
				message += cleanUp(s.id) + ", ";
			}
			// remove the final comma that's not needed
			message = message.slice(0, -2);
		}
	}

	if (message.length > 0)
	{
		message = "The following fields are required before submitting:\n" + message;
		alert(message);
		return false;
	}
	else
	{
		return true;
	}
}

// replace underscores with spaces and capitalize the first letter of each word
function cleanUp(string)
{
	return string.replace(/_/g, ' ').replace(/\b[a-z]/g,function(f){return f.toUpperCase();})
}
