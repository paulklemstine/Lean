/-! # CatalogBuild.Bridges.TopologyBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 7
-/

import Mathlib

/-- Open complement is closed. -/
theorem open_compl_is_closed {X : Type*} [TopologicalSpace X]
    {s : Set X} (h : IsOpen s) :
    IsClosed sᶜ :=
  IsOpen.isClosed_compl h


/-- Closed complement is open. -/
theorem closed_compl_is_open {X : Type*} [TopologicalSpace X]
    {s : Set X} [IsClosed s] :
    IsOpen sᶜ :=
  IsClosed.isOpen_compl


/-- Compact sets are closed in Hausdorff spaces. -/
theorem compact_is_closed {X : Type*} [TopologicalSpace X] [T2Space X]
    {s : Set X} (h : IsCompact s) :
    IsClosed s :=
  IsCompact.isClosed h


/-- Intersection of compact sets is compact in Hausdorff spaces. -/
theorem compact_inter {X : Type*} [TopologicalSpace X] [T2Space X]
    {s t : Set X} (hs : IsCompact s) (ht : IsCompact t) :
    IsCompact (s ∩ t) :=
  IsCompact.inter hs ht


/-- Every set is contained in its closure: s ⊆ closure s. -/
theorem subset_own_closure {X : Type*} [TopologicalSpace X]
    {s : Set X} :
    s ⊆ closure s :=
  subset_closure


/-- Closed sets are their own closure. -/
theorem closure_eq_self {X : Type*} [TopologicalSpace X]
    {s : Set X} (h : IsClosed s) :
    closure s = s :=
  IsClosed.closure_eq h


/-- A closed subset of a compact space is compact. -/
theorem closed_of_compact_is_compact {X : Type*} [TopologicalSpace X]
    [CompactSpace X] {s : Set X} (hs : IsClosed s) :
    IsCompact s :=
  hs.isCompact

