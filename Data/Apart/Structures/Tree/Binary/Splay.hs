module Data.Apart.Structures.Tree.Binary.Splay (search, insert) where


import "base" Data.Function ((&))
import "base" Data.Foldable (find)
import "comonad" Control.Comonad (Comonad (..))
import "contravariant" Data.Functor.Contravariant (Predicate (..))
import "semigroupoids" Data.Functor.Bind (Bind (..))


import Data.Apart.Transformations (Segmented (..))
import Data.Apart.Structures.Tree.Binary (Binary, Branches (..), ls, gt)
import qualified Data.Apart.Structures.Tree.Binary as Binary (insert)
import Data.Apart.Structures.Tree.Binary.Rotation (Rotate (..), rtt)

-- | Splay tree after each insert.
insert :: Ord a => a -> Binary a -> Segmented Binary a
insert x t = splay x $ Binary.insert t x

-- | If needed element not in the root - it isn't found.
search :: Eq a => a -> Binary a -> Segmented Binary a
search x t = maybe End (const $ splay x t) $ find (== x) t

left_zig :: Eq a => Predicate (a, Binary a)
left_zig = Predicate $ \ (x, t) -> gt t
	& foldr (\g _ -> extract g == x) False

right_zig :: Eq a => Predicate (a, Binary a)
right_zig = Predicate $ \ (x, t) -> ls t
	& foldr (\l _ -> extract l == x) False

left_zig_zig :: Eq a => Predicate (a, Binary a)
left_zig_zig = Predicate $ \ (x, t) -> gt t >>- gt
	& foldr (\gg _ -> extract gg == x) False

right_zig_zig :: Eq a => Predicate (a, Binary a)
right_zig_zig = Predicate $ \ (x, t) -> ls t >>- ls
	& foldr (\ll _ -> extract ll == x) False

left_zig_zag :: Eq a => Predicate (a, Binary a)
left_zig_zag = Predicate $ \ (x, t) -> gt t >>- ls
	& foldr (\gl _ -> extract gl == x) False

right_zig_zag :: Eq a => Predicate (a, Binary a)
right_zig_zag = Predicate $ \ (x, t) -> ls t >>- gt
	& foldr (\lg _ -> extract lg == x) False

splay :: Eq a => a -> Binary a -> Segmented Binary a
splay x t@(getPredicate left_zig . (x,) -> True) = rtt L t
splay x t@(getPredicate right_zig . (x,) -> True) = rtt R t
splay x t@(getPredicate left_zig_zig . (x,) -> True) = rtt LL t
splay x t@(getPredicate right_zig_zig . (x,) -> True) = rtt RR t
splay x t@(getPredicate left_zig_zag . (x,) -> True) = rtt RL t
splay x t@(getPredicate right_zig_zag . (x,) -> True) = rtt LR t
