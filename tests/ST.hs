{-# LANGUAGE Rank2Types #-}
module ST (
    tests_STPermute
    ) where
    
import Control.Monad
import Control.Monad.ST

import Data.Permute
import Data.Permute.ST


import Driver
import Debug.Trace
import Test.QuickCheck
import Text.Printf
    
import Test.Permute()
import qualified Test.Permute as Test

newPermute_S n = permute n
prop_NewPermute (Nat n) = 
    newPermute n `equivalent` newPermute_S n

newListPermute_S n is = listPermute n is
prop_NewListPermute (ListPermute n is) =
    newListPermute n is `equivalent` newListPermute_S n is

getElems_S p = (elems p, p)
prop_GetElems = getElems `implements` getElems_S

tests_STPermute = 
    [ ("newPermute"     , mytest prop_NewPermute)
    , ("newListPermute" , mytest prop_NewListPermute)
    , ("getElems"       , mytest prop_GetElems)
    ]


------------------------------------------------------------------------
-- 
-- The specification language
--
    
abstract :: STPermute s -> ST s Permute
abstract = freeze

commutes :: (Eq a, Show a) =>
    STPermute s -> (STPermute s -> ST s a) ->
        (Permute -> (a,Permute)) -> ST s Bool
commutes p a f = do
    old <- abstract p
    r   <- a p
    new <- abstract p
    let s      = f old
        s'     = (r,new)
        passed = s == s'
        
    when (not passed) $
        trace (printf ("expected `%s' but got `%s'") (show s) (show s'))
              return ()
              
    return passed

equivalent :: (forall s . ST s (STPermute s)) -> Permute -> Bool
equivalent p s = runST $ do
    p' <- (p >>= abstract)
    when (not $ p' == s) $
        trace (printf ("expected `%s' but got `%s'") (show s) (show p'))
            return ()
    return (p' == s)
    
implements :: (Eq a, Show a) =>
    (forall s . STPermute s -> ST s a) ->
    (Permute -> (a,Permute)) -> 
        Property
a `implements` f =
    forAll arbitrary $ \(Nat n) ->
        implementsFor n a f

implementsFor :: (Eq a, Show a) =>
    Int ->
    (forall s . STPermute s -> ST s a) ->
    (Permute -> (a,Permute)) -> 
        Property
implementsFor n a f =
    forAll (Test.permute n) $ \p ->
        runST $ do
            p' <- unsafeThaw p
            commutes p' a f

implementsIf :: (Eq a, Show a) =>
    (forall s . STPermute s -> ST s Bool) ->
    (forall s . STPermute s -> ST s a) ->
    (Permute -> (a, Permute)) -> 
        Property
implementsIf pre a f =
    forAll arbitrary $ \p ->
        runST ( do
            p' <- thaw p
            pre p') ==>
        runST ( do
            p' <- unsafeThaw p
            commutes p' a f )
