var RequiredBlueprint    = null;
var HasCooldown          = false;

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

    if (item.action === 'toggle') {
      item.toggle ? $("#crafting").fadeIn() : $("#crafting").fadeOut();

      if (item.toggle){
        LoadBackgroundImage('default');

        CurrentPageType = "MAIN";
        CurrentPageClassName = "mainpage";

        $('.mainpage').fadeIn();

      }

    } else if (event.data.action == "loadInformation"){
      var prod_crafting = event.data.crafting_det;

      $("#crafting-title").text(prod_crafting.header);
      $("#crafting-description").text(prod_crafting.description);

    } else if (event.data.action == "clearRecipes"){
      $('#recipes').html('');

    } else if (event.data.action == "loadCategory"){
			$("#categories").append( `<div id="categories-main" ></div>` + `<div category = "` + event.data.category + `" id="categories-label">` + event.data.label + `</div>` );
    
    } else if (event.data.action == "loadCategoryRecipe"){

      if (event.data.locked) {
        $("#recipes").append( `<div id="recipes-main" ></div>` + `<div locked = "1" recipe = "` + event.data.recipe + `" id="recipes-label" style = "color: rgba(34, 34, 34, 0.442); text-decoration-line: line-through; ">` + event.data.label + `</div>` );
      }else{
        $("#recipes").append( `<div id="recipes-main" ></div>` + `<div locked = "0" recipe = "` + event.data.recipe + `" id="recipes-label">` + event.data.label + `</div>` );
      }

    } else if (event.data.action == "loadSelectedRecipe"){
      var prod_recipe = event.data.result;

      if (prod_recipe.RequiredBlueprint != false && Number(event.data.locked) == 1 ) {
        RequiredBlueprint = prod_recipe.RequiredBlueprint;
        SetRecipeAsNotReadable();

        $('#recipe-insufficient-knowledge-title').text(Locales.InsufficientKnowledge);
        $("#recipe-insufficient-knowledge-button").text(Locales.ReadBlueprintActionButton);
        $("#recipe-insufficient-knowledge-description").text(Locales.RequiredBlueprint.replaceAll('%s', prod_recipe.RequiredBlueprintLabel));

        $("#recipe-image-background").css('opacity', 0.2);
      }else{
        $("#recipe-image-background").css('opacity', 0.8);
        $('#recipe-craft-button').text(prod_recipe.ActionDisplay);
      }

      $("#recipe-image-background").hide();
      document.getElementById("recipe-image-background").style.backgroundImage = null;

      $('#recipe-ingredients-title').text(Locales.IngredientsTitle.replaceAll('%s', prod_recipe.Quantity));

      $('#recipe-title').text(prod_recipe.Label);
      $('#recipe-description').text(prod_recipe.RecipeInformation);
  
      if (prod_recipe.BackgroundImage) {

        const image = 'img/backgrounds/' + prod_recipe.BackgroundImage;
        load(image).then(() => {
  
          document.getElementById("recipe-image-background").style.backgroundImage = `url(${image})`;
          $("#recipe-image-background").show();
          $(".selectedrecipepage").fadeIn(1000);

        });

      }else{
        $(".selectedrecipepage").fadeIn(1000);
      }

      setTimeout(()=>{ HasCooldown = false; }, 1100);

    } else if (event.data.action == "loadSelectedRecipeIngredients"){

      if (RequiredBlueprint != null && RequiredBlueprint != false ) {
        $("#ingredients").append( `<div id="ingredients-main" ></div>` + `<div id="ingredients-label" style = "color: transparent; text-shadow: 0 0 8px #000;" >X` + event.data.quantity + " " + event.data.label + `</div>` );

      }else {
        $("#ingredients").append( `<div id="ingredients-main" ></div>` + `<div id="ingredients-label">X` + event.data.quantity + " " + event.data.label + `</div>` );
      }

    } else if (event.data.action == "resetCooldown"){
      HasCooldown = false;

    } else if (event.data.action == "sendNotification") {
      var prod_notify = event.data.notification_data;
      sendNotification(prod_notify.message, prod_notify.color);

    } else if (event.data.action == "close") {
      CloseNUI();
    }

  });

  $("body").on("keyup", function (key) {
    if (key.which == 27){ 
      CurrentPageType == "MAIN" || CurrentPageType == null ? CloseNUI() : OnBackButtonAction();
    } 
  });


  /*-----------------------------------------------------------
   Back Button Actions
  -----------------------------------------------------------*/

  function OnBackButtonAction(){
    playAudio("button_click.wav");

    $('#recipes').html('');

    $('.' + CurrentPageClassName).fadeOut();
    $('.mainpage').fadeIn();

    CurrentPageType = "MAIN";
    CurrentPageClassName = "mainpage";

    $('#ingredients').html('');

    $('#recipe-title').text('');
    $('#recipe-description').text('');
    $('#recipe-ingredients-title').text('');
    $('#recipe-craft-button').text('');
    $('#recipe-insufficient-knowledge-title').text('');
    $("#recipe-insufficient-knowledge-description").text('');
    $("#recipe-insufficient-knowledge-button").text('');

    $(".selectedrecipepage").fadeOut();

    RequiredBlueprint = null;
    HasCooldown = false;
  }

  /*-----------------------------------------------------------
  Actions
  -----------------------------------------------------------*/

  // @categories-label : Displaying category recipes.
  $("#crafting").on("click", "#categories-label", function() {
    playAudio("button_click.wav");

    var $button    = $(this);
    var $category = $button.attr('category');

    $.post("http://tpz_crafting/requestCategoryRecipes", JSON.stringify({ 
      category : $category,
    }));

    CurrentPageType = "RECIPES";
    CurrentPageClassName = "recipespage";
    
    $('.mainpage').fadeOut();
    $('.recipespage').fadeIn();
  });

  
  $("#crafting").on("click", "#recipes-label", function() {

    if (HasCooldown) { return; }
    HasCooldown = true;

    playAudio("button_click.wav");
    
    var $button = $(this);
    var $locked = $button.attr('locked');
    var $recipe = $button.attr('recipe');

    RequiredBlueprint = null;

    $(".selectedrecipepage").fadeOut();

    ResetUnreadableElements();

    $('#ingredients').html('');

    $('#recipe-title').text('');
    $('#recipe-description').text('');
    $('#recipe-ingredients-title').text('');
    $('#recipe-craft-button').text('');
    $('#recipe-insufficient-knowledge-title').text('');
    $("#recipe-insufficient-knowledge-description").text('');
    $("#recipe-insufficient-knowledge-button").text('');

    $.post("http://tpz_crafting/requestRecipe", JSON.stringify({ 
      locked : $locked,
      recipe : $recipe,
    }));

  });

  /*-----------------------------------------------------------
    Crafting Actions
  -----------------------------------------------------------*/

  $("#crafting").on("click", "#recipe-craft-button", function() {

    if (HasCooldown) { return; }
    HasCooldown = true;

    playAudio("button_click.wav");

    $.post("http://tpz_crafting/craftSelectedRecipe", JSON.stringify({  }));

  });


  $("#crafting").on("click", "#recipe-insufficient-knowledge-button", function() {

    if (HasCooldown) { return; }
    HasCooldown = true;

    playAudio("button_click.wav");

    $.post("http://tpz_crafting/readSelectedRecipeBlueprint", JSON.stringify({  }));

  });

});

