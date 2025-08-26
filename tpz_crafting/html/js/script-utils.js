
var CurrentPageClassName = null;
var CurrentPageType      = null;

var IsWriting            = false;

let SELECTED_RECIPE_DIV_CLASS = null;
let MAIN_NUI_HEADER_TITLE = null;
let MAIN_NUI_HEADER_DESCRIPTION = null;

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ${FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 

  $("#crafting").hide();

  displayPage("mainpage", "visible");
  $(".mainpage").fadeOut();

  displayPage("recipespage", "visible");
  $(".recipespage").fadeOut();

  displayPage("selectedrecipepage", "visible");
  $(".selectedrecipepage").fadeOut();

  displayPage("notification", "visible");
  $(".notification").fadeOut();

}) .catch( err => { console.error(err); });


function playAudio(sound) {
	var audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

function sendNotification(text, color, cooldown){

  cooldown = cooldown == cooldown == null || cooldown == 0 || cooldown === undefined ? 4000 : cooldown;

  $("#notification_message").text(text);
  $("#notification_message").css("color", color);
  $("#notification_message").fadeIn();

  setTimeout(function() { $("#notification_message").text(""); $("#notification_message").fadeOut(); }, cooldown);
}

function load(src) {
  return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', resolve);
      image.addEventListener('error', reject);
      image.src = src;
  });
}

function randomIntFromInterval(min, max) { // min and max included 
  return Math.floor(Math.random() * (max - min + 1) + min)
}

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function onNumbers(evt){
  // Only ASCII character in that range allowed
  var ASCIICode = (evt.which) ? evt.which : evt.keyCode;
  
  if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57))
      return false;
  return true;
}

function LoadBackgroundImage(imageUrl) {
  const image = 'img/' + imageUrl + '.png';
  load(image).then(() => {
    document.getElementById("crafting").style.backgroundImage = `url(${image})`;
  });
}

function WriteText(elementId, inputText, inputSpeed) {
  var text = inputText;

  var writer = "";
  writer.length = 0; //Clean the string

  var maxLength = text.length;
  var count = 0;
  var speed = inputSpeed / maxLength; //The speed of the writing depends of the quantity of text

  //playAudio("scribble.mp3"); // play hand write

  var write = setInterval(function() {

    document.getElementById(elementId).innerHTML += text[count++];

    if ($("#" + elementId).text().match(inputText)) {
      clearInterval(write); 
    }

  }, speed);
}

function IsStringNotValid(str) {
  return (typeof str === "string" && str.length === 0) || str === null || str === undefined || typeof str === undefined;
}

function ResetUnreadableElements(){
  $('#recipe-ingredients-title').css('color', 'rgba(31, 31, 31, 0.747)');
  $('#recipe-ingredients-title').css('text-shadow', 'none');

  $('#recipe-craft-button').css('color', 'rgba(31, 31, 31, 0.747)');
  $('#recipe-craft-button').css('text-shadow', 'none');

  $('#recipe-title').css('color', 'rgba(31, 31, 31, 0.747)');
  $('#recipe-title').css('text-shadow', 'none');

  $('#recipe-description').css('color', 'rgba(31, 31, 31, 0.747)');
  $('#recipe-description').css('text-shadow', 'none');
}

function SetRecipeAsNotReadable(){
  $('#recipe-ingredients-title').css('color', 'transparent');
  $('#recipe-ingredients-title').css('text-shadow', '0 0 8px #000');

  $('#recipe-craft-button').css('color', 'transparent');
  $('#recipe-craft-button').css('text-shadow', '0 0 8px #000');

  $('#recipe-title').css('color', 'transparent');
  $('#recipe-title').css('text-shadow', '0 0 8px #000');

  $('#recipe-description').css('color', 'transparent');
  $('#recipe-description').css('text-shadow', '0 0 8px #000');
}

function CloseNUI() {
  
  MAIN_NUI_HEADER_TITLE = null;
  MAIN_NUI_HEADER_DESCRIPTION = null;

  $('#crafting').fadeOut();

  $(".mainpage").fadeOut();
  $(".recipespage").fadeOut();
  $(".selectedrecipepage").fadeOut();

  $(".notification").fadeOut();

  $('#categories').html('');
  $('#recipes').html('');
  $('#ingredients').html('');

  HasCooldown = false;

	$.post('http://tpz_crafting/close', JSON.stringify({}));
}
