module Test.Apart.Structures.Tree.Binary
	( any_left_left_is_less_any_right_is_greater) where

import "base" Data.Functor.Bind (Bind (..))
import "comonad" Control.Comonad (extract)
import "hedgehog" Hedgehog (Property (..), Gen (..), forAll, property, assert)
import "hedgehog" Hedgehog.Gen (enumBounded, list)
import "hedgehog" Hedgehog.Range (linear)


import Data.Apart.Structures.Tree.Binary (Binary, ls, gt, singleton, insert)

gen_singleton_binary_tree :: Gen (Binary Int)
gen_singleton_binary_tree = singleton <$> enumBounded

any_left_left_is_less_any_right_is_greater :: Property
any_left_left_is_less_any_right_is_greater = property $ do
	xs <- forAll $ list (linear 0 100) (enumBounded :: Gen Int)
	binary <- forAll $ gen_singleton_binary_tree
	let inserted = foldr (flip insert) binary xs
	let all_less_than_focus = all ((extract inserted) >=) <$> ls inserted
	assert $ foldr (==) True all_less_than_focus
