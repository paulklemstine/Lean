/-! # CatalogBuild.Bridges.TopologicalConnectednessBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6
-/

import Mathlib

/-- Closed intervals [a,b] are connected. -/
theorem Icc_connected {α : Type*} [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [DenselyOrdered α] {a b : α} (hab : a ≤ b) :
    IsConnected (Set.Icc a b) :=
  isConnected_Icc hab


/-- Semi-infinite intervals [a,∞) are connected. -/
theorem Ici_connected {α : Type*} [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [DenselyOrdered α] (a : α) :
    IsConnected (Set.Ici a) :=
  isConnected_Ici


/-- Semi-infinite intervals (-∞,a] are connected. -/
theorem Iic_connected {α : Type*} [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [DenselyOrdered α] (a : α) :
    IsConnected (Set.Iic a) :=
  isConnected_Iic


/-- **Generalized IVT**: the continuous image of a preconnected set
is preconnected. This is the topological REASON why sign changes
guarantee roots: ℝ intervals are connected, and the continuous
image of connected sets contains all intermediate values. -/
theorem continuous_image_preconnected {α β : Type*} [TopologicalSpace α]
    [TopologicalSpace β] {s : Set α} (hs : IsPreconnected s)
    (f : α → β) (hf : ContinuousOn f s) :
    IsPreconnected (f '' s) :=
  IsPreconnected.image hs f hf


/-- The continuous image of a connected set is connected. -/
theorem continuous_image_connected {α β : Type*} [TopologicalSpace α]
    [TopologicalSpace β] {s : Set α} (hs : IsConnected s)
    (f : α → β) (hf : ContinuousOn f s) :
    IsConnected (f '' s) :=
  IsConnected.image hs f hf


/-- Union of connected sets with nonempty intersection is connected. -/
theorem union_connected {α : Type*} [TopologicalSpace α] {s t : Set α}
    (hs : IsConnected s) (ht : IsConnected t) (hst : (s ∩ t).Nonempty) :
    IsConnected (s ∪ t) :=
  IsConnected.union hst hs ht

