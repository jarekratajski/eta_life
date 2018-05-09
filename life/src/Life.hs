module Life where

import Data.Array
import Data.Maybe
import Data.Bits
import Debug.Trace


data Color = Color  {red :: Int,
                                                             green :: Int,
                                                             blue :: Int};

data  Cell  = Dead | Alive {color :: Color}

type Row = Array Int Cell
type Plane = Array Int Row


takeRow:: Plane->Int->Maybe Row
takeRow plane y
      | (y>= minBound && y <=maxBound) = Just $ plane!y
      | otherwise =  Nothing
      where
         myBounds = bounds  plane
         minBound = fst myBounds
         maxBound = snd myBounds

takeCell:: Row->Int->Maybe Cell
takeCell row x
      | (x>= minBound && x <=maxBound) = Just $ row!x
      | otherwise =  Nothing
      where
         myBounds = bounds  row
         minBound = fst myBounds
         maxBound = snd myBounds


takeRows::Int->Plane->[Row]
takeRows y plane = catMaybes maybeRows
     where
         rows = [y-1, y, y+1]
         maybeRows =  (takeRow plane) <$> rows

takeCells::[Row]->Int->[Cell]
takeCells rows x = catMaybes $ concat  allCells
       where
            columns = [x-1, x, x+1]
            allCells = (\row -> takeCell row <$> columns ) <$> rows


neighborhood::Int->Int ->Plane->[Cell]
neighborhood x y  plane  = takeCells rows x
            where rows = takeRows y plane


newCell::[Cell]->Cell->Cell
newCell cells Dead = if alive ==3 then Alive { color = snd vals} else Dead
   where
         vals = newCellValue cells (0, Color {red = 0,green = 0, blue = 0})
         alive = fst vals
newCell cells Alive{color = c} = if alive ==3 || alive==4  then Alive { color = c} else Dead
   where
         vals = newCellValue cells (0, c)
         alive = fst vals



newCellValue::[Cell]->(Int, Color)->(Int, Color)
newCellValue [] (cnt, color) = (cnt, color)
newCellValue (Dead:xs) (cnt, color) = newCellValue xs (cnt, color)
newCellValue (Alive {color = c} :xs) (cnt, color) = newCellValue xs  (cnt+1, mixC color c)


calcCell::Cell->Int -> Int -> Plane -> Cell
calcCell cell x y  plane = aNew
         where
               ngh = neighborhood x y plane
               aNew = newCell ngh cell

showCell::Cell->String
showCell Dead = "."
showCell _ = "O"

mixC::Color->Color->Color
mixC a b = Color { red  = red a .|. red b,
                               blue  = blue a .|. blue b,
                               green = green a .|. green b}


cellFromColor::Color->Cell
cellFromColor Color { red = 0, green = 0 , blue = 0 } = Dead
cellFromColor col  = Alive { color = col}


mix::Int->Int->Int
mix a b = a .|. b


makePlane::Int->Int->Plane
makePlane wi hi = array (0, hi) [  (i, makeRow wi) | i <- [0..hi] ]


makeRow::Int->Row
makeRow wi = array (0,wi) [  (i, Dead) | i<- [0..wi] ]



setCell::Plane->Int->Int->Cell->Plane
setCell plane x y cell = plane // [(y , newRow)]
      where
            row = plane ! y
            newRow = row // [(x, cell)]


-- actuall processing
processRow::Row->Plane->Int->Row
processRow row plane y = row // newElems
      where
            elements  = assocs row
            newElems =(\(x,cell) -> (x, calcCell cell x y plane) )  <$> elements

processPlane::Plane->Plane
processPlane plane = plane // newElems
      where
            elements  = assocs plane
            newElems =(\(y,row) -> (y, processRow row  plane y) )  <$> elements