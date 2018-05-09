module Main where

import Life
import Java
import Foreign.StablePtr
import Data.Array
import Data.Bits

type GOLState = StablePtr Plane

data JColor = JColor @java.awt.Color
  deriving Class

data BufferedImage = BufferedImage  @java.awt.image.BufferedImage
    deriving Class

foreign import java unsafe "getGreen" getGreen
  :: Java JColor Int

foreign import java unsafe "getRed" getRed
    :: Java JColor Int
foreign import java unsafe "getBlue" getBlue
    :: Java JColor Int

foreign import java unsafe "setRGB" setRGB :: BufferedImage->Int->Int->Int->IO  ()

initEmptyXP:: Int -> Int -> IO GOLState
initEmptyXP wi hi = newStablePtr $ makePlane wi hi


setCellXP::GOLState->Int->Int->JColor->IO GOLState
setCellXP state x y color = do
                                    red <- javaWith color  getRed
                                    green <- javaWith color  getGreen
                                    blue <- javaWith color getBlue
                                    let color = Color { red = red, green = green , blue  = blue}
                                    let cell  = cellFromColor color
                                    plane <- deRefStablePtr state
                                    newStablePtr $ setCell plane x y cell

newStateXP::GOLState -> IO GOLState
newStateXP state =  ( deRefStablePtr state) >>= (newStablePtr . processPlane)


fillImageXP::GOLState->BufferedImage->IO BufferedImage
fillImageXP state image = do
               plane <- deRefStablePtr state
               let rows = assocs plane
               let cells = (\(y, row) -> ( (\(x, cell) -> (x,y,cell) ) <$>assocs row)  ) <$> rows
               let result = foldl ( \img (x,y,cell) -> ioSet x y cell img ) (return image)  (concat cells)
               result


ioSet::Int->Int->Cell->IO BufferedImage->IO BufferedImage
ioSet x y cell image = image >>= (setPixel x y cell )

setPixel::Int->Int->Cell->BufferedImage->IO BufferedImage
setPixel x y Dead image =   (  setRGB image x y  0)  >>  return image
setPixel x y Alive{color = c} image =   (  setRGB image x y  (cellToRgb c) )  >>  return image


cellToRgb::Color->Int
cellToRgb Color{ red = r, green = g,  blue = b} = (shift r 16) .|. (shift g 8) .|. b

foreign export java "@static pl.setblack.life.Life.initEmpty" initEmptyXP
  :: Int -> Int -> IO (GOLState)

foreign export java "@static pl.setblack.life.Life.setCell" setCellXP
   ::GOLState->Int->Int->JColor->IO GOLState

foreign export java "@static pl.setblack.life.Life.newState" newStateXP
   ::GOLState->IO GOLState

foreign export java "@static pl.setblack.life.Life.fillImage" fillImageXP
   ::GOLState->BufferedImage->IO BufferedImage



main = do
        putStrLn $ "this is library in fact"