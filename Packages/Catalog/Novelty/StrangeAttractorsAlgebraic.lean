import Mathlib

/-!
# Finite graph approximants and a Cantor inverse limit

Binary de Bruijn graphs give a concrete finite directed-graph model for symbolic
dynamics.  Vertices at level `n` are binary words of length `n + 1`; an edge
records a one-symbol left shift.  Deleting the final symbol is a bonding map of
directed graphs.  Compatible finite prefixes form an inverse limit, and every
infinite binary stream determines a distinct point of that limit.
-/

namespace StrangeAttractorsAlgebraic

/-- Binary words of length `n`. -/
abbrev Word (n : ℕ) := Fin n → Bool

/-- Delete the final symbol of a binary word. -/
def truncate (n : ℕ) (w : Word (n + 1)) : Word n :=
  fun i => w ⟨i, Nat.lt_succ_of_lt i.isLt⟩

/-- The edge relation of the binary de Bruijn graph of order `n + 1`.
There is an edge from `u` to `v` when the final `n` symbols of `u` are the
initial `n` symbols of `v`. -/
def deBruijnEdge (n : ℕ) (u v : Word (n + 1)) : Prop :=
  ∀ i : Fin n,
    u ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩ =
      v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩

/-- The level of binary words of length `n` has exactly `2^n` vertices. -/
theorem word_card (n : ℕ) : Fintype.card (Word n) = 2 ^ n := by
  simp [Word]

/-- Prefix deletion is a directed-graph morphism between consecutive binary
de Bruijn graphs. -/
theorem truncate_preserves_edge (n : ℕ) {u v : Word (n + 2)}
    (h : deBruijnEdge (n + 1) u v) :
    deBruijnEdge n (truncate (n + 1) u) (truncate (n + 1) v) := by
  intro i
  simp [truncate]
  exact h ⟨i.val, by exact Nat.lt_succ_of_lt i.isLt⟩

/-- The inverse limit of the finite binary-prefix diagram. -/
def PrefixLimit :=
  {x : ∀ n, Word n // ∀ n, truncate n (x (n + 1)) = x n}

/-- The compatible family of finite prefixes of an infinite binary stream. -/
def streamToLimit (s : ℕ → Bool) : PrefixLimit :=
  ⟨fun n i => s i, by
    intro n
    funext i
    rfl⟩

/-- Distinct symbolic trajectories remain distinct in the inverse limit of the
finite graph approximants. -/
theorem streamToLimit_injective : Function.Injective streamToLimit := by
  intro s t h
  ext n
  have := congr_arg Subtype.val h
  have h' := congr_fun (congr_fun this (n + 1)) ⟨n, Nat.lt_succ_self n⟩
  simp at h'
  exact h'

/-- The inverse limit contains infinitely many points; in fact the preceding
injection exhibits a full Cantor family of compatible threads. -/
theorem prefixLimit_infinite : Infinite PrefixLimit := by
  exact Infinite.of_injective streamToLimit streamToLimit_injective

end StrangeAttractorsAlgebraic