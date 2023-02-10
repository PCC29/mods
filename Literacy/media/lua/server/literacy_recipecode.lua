require 'recipecode'

function Recipe.OnTest.CreateLiteracyMag(item)
    return (SandboxVars.Literacy.WantLiteracyMag and SandboxVars.Literacy.LiteracyMagCraftable)
end