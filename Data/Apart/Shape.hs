module Data.Apart.Shape (Shape (..)) where

import "base" Data.Bifoldable (Bifoldable (..))
import "base" Data.Bifunctor (Bifunctor (..))
import "base" Data.Bitraversable (Bitraversable (..))
import "base" Data.Semigroup (Semigroup (..))
import "semigroupoids" Data.Functor.Apply (Apply (..))
import "semigroupoids" Data.Functor.Alt (Alt (..))

-- | Type that can tell you about aggregate state of your structure.
data Shape t raw value
	= Ready (t value) -- ^ Segment of values in memory
	| Converted raw -- ^ Segment of values somewhere else

instance (Show (t value), Show value, Show raw) => Show (Shape t raw value) where
	show (Ready values)  = show values
	show (Converted raw) = "{" <> show raw <> "}"

instance Functor t => Functor (Shape t raw) where
	fmap f (Ready values)  = Ready $ f <$> values
	fmap f (Converted raw) = Converted raw

instance Apply t => Apply (Shape t raw) where
	Ready fs <.> Ready xs = Ready $ fs <.> xs
	Ready fs <.> Converted raw = Converted raw
	Converted raw <.> _ = Converted raw

instance Alt t => Alt (Shape t raw) where
	Converted raw <!> x = x
	Ready xs <!> _ = Ready xs

instance Foldable t => Foldable (Shape t raw) where
	foldr f acc (Ready values)  = foldr f acc values
	foldr f acc (Converted raw) = acc

instance Traversable t => Traversable (Shape t raw) where
	traverse f (Ready values)  = Ready <$> traverse f values
	traverse _ (Converted raw) = pure $ Converted raw

instance Functor t => Bifunctor (Shape t) where
	bimap _ f (Ready values)  = Ready $ f <$> values
	bimap g _ (Converted raw) = Converted $ g raw

instance Foldable t => Bifoldable (Shape t) where
	bifoldr _ f acc (Ready values)  = foldr f acc values
	bifoldr g _ acc (Converted raw) = g raw acc

instance Traversable t => Bitraversable (Shape t) where
	bitraverse _ f (Ready values)  = Ready <$> traverse f values
	bitraverse g _ (Converted raw) = Converted <$> g raw
