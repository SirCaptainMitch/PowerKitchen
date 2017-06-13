#https://geekeefy.wordpress.com/2017/01/12/get-nutrient-composition-of-food-items-using-powershell/
$html = New-Object -ComObject "HTMLFile"

$uri = 'http://damndelicious.net/2017/04/21/korean-beef-bowl-meal-prep/'

$site = Invoke-WebRequest -Uri $uri

# $site.ParsedHtml | gm
# recipe class
$recipe = $site.ParsedHtml.getElementsByTagName('div') |
    Where-Object {$_.getAttributeNode('class').Value -eq 'recipe'}

$recipeCard = $recipe.textContent

$ingredients = $recipe.getElementsByTagName('div') |
     Where-Object {$_.getAttributeNode('class').Value -eq 'ingredients'}

$instructions = $recipe.getElementsByTagName('div') |
     Where-Object {$_.getAttributeNode('class').Value -eq 'instructions'}

$meta = ($recipe.getElementsByTagName('div') | Where-Object {$_.getAttributeNode('class').Value -like '*time*' } ).getElementsByTagName('p')

$recipeName = $recipe.getElementsByTagName('h2') |
     Where-Object {$_.getAttributeNode('itemProp').Value -eq 'name'}

# TODO: This should be a class
$recipeObject = [PSCustomObject]@{
    Name = $recipeName.InnerText
    Ingredients = @()
    Instructions = @()
    Url = $uri
    Card = $recipeCard
}

#regex declares

# Meta Data
foreach  ( $tag in $meta ) {
        $tagName = $($tag.getElementsByTagName('strong')).InnerText
        $tagName = $tagName -replace ':'
        $tagName = $tagName -replace 'Time'

        $content = $($tag.InnerText).split(':')[1].trim()

        Add-Member -InputObject $recipeObject -MemberType NoteProperty -Name $tagName -Value $content -
}

# Ingredients
foreach  ( $ingredient in $ingredients ) {
        $recipeObject.Ingredients += $ingredient.InnerText
}

# Instructions
foreach  ( $instruction in $instructions ) {
        $recipeObject.Instructions += $instruction.InnerText
}


$recipeObject | format-list