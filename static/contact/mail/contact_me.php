<?php
$dest_handle = 'contact';
$dest_addr   = '';

// check whether configured
if (!$dest_addr) {
	echo "Configuration error - please inform webmaster!";
	return false;
}

// Check for empty fields
if (empty ($_POST ['name'])  	||
    empty ($_POST ['email']) 	||
    empty ($_POST ['phone']) 	||
    empty ($_POST ['message'])	||
    !filter_var ($_POST ['email'], FILTER_VALIDATE_EMAIL)) {
	echo "No or insufficient arguments provided!";
	return false;
   }

$name          = $_POST ['name'];
$email_address = $_POST ['email'];
$phone         = $_POST ['phone'];
$message       = $_POST ['message'];

// Create the email and send the message
$to            = "$dest_handle@$dest_addr";
$email_subject = "Website Contact Form: $name";
$email_body    = "You have received a new message from your "
	       . "website contact form.\r\n"
               . "Here are the details:\r\n\r\n"
               . "Name: $name\r\n"
               . "Email: $email_address\r\n"
               . "Phone: $phone\r\n\r\n"
               . "Message:\r\n"
	       . "$message\r\n"
	       . "End\r\n";
$headers       = "From: noreply@$dest_addr\r\n"
               . "Reply-To: $email_address\r\n";

// Send ...
if (!mail ($to,$email_subject,$email_body,$headers)) {
	echo "Something went wrong sending mail from $email_address!";
	return false;
}

return true;
?>
