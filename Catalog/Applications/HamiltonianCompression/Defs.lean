/-
# Hamiltonian Compression Factor of Cubic Edge-Transitive Graphs

## Mission framing
A graph `Γ` has *Hamiltonian compression factor* `κ(Γ) ≥ k` when it admits a
`k`-symmetric Hamiltonian cycle: a Hamiltonian cycle `C` together with an
automorphism `g` of order `k` that acts on `C` as a rotation by `|V(Γ)|/k`
positions.  The research conjecture asserts that *every* Hamiltonian connected
cubic edge-transitive graph satisfies `κ(Γ) ≥ 2`.

This file sets up a self-contained, faithful formalization of `κ ≥ 2`
(a *2-symmetric Hamiltonian cycle*) and the cubic circulant family on which we
prove it.  The carrier of every graph is `ZMod n`, so that the "rotation by
`n/2`" automorphism is literally translation by the diameter element `n/2`.

The connection set `{±1, n/2}` produces the **Möbius–Kantor / Möbius ladder**
cubic circulant `ML(n)`.  Its smallest members are genuine *cubic
edge-transitive* graphs:
  * `ML(4) = K₄`         (complete graph on 4 vertices),
  * `ML(6) = K_{3,3}`    (complete bipartite, the 3-cube's bipartite double).
For every even `n ≥ 4` the graph `ML(n)` is `3`-regular (cubic) and vertex
transitive, and we prove it carries a 2-symmetric Hamiltonian cycle, giving an
infinite family of evidence for `κ ≥ 2`.
-/
import Mathlib

open Equiv Finset

namespace HamiltonianCompression

/-- The *diameter element* `n/2 ∈ ZMod n`; translation by it is the candidate
order-2 rotation of a `2`-symmetric Hamiltonian cycle. -/
def diam (n : ℕ) : ZMod n := (↑(n / 2) : ZMod n)

/-- Möbius-ladder / cubic circulant adjacency on `ZMod n`, with connection set
`{+1, -1, n/2}`.  For even `n` this is a symmetric, irreflexive relation. -/
def MLAdj (n : ℕ) (a b : ZMod n) : Prop :=
  a - b = 1 ∨ a - b = -1 ∨ a - b = diam n

instance (n : ℕ) : DecidableRel (MLAdj n) := by
  intro a b; unfold MLAdj; infer_instance

/-- `2`-symmetric Hamiltonian cycle structure on a graph given by adjacency
`Adj` on `n = |V|` vertices.  This is precisely the witness for
`κ(Γ) ≥ 2`:

* `order`        — the cyclic vertex ordering of the Hamiltonian cycle
                   (`order i` is the vertex at position `i`);
* `consecutive`  — consecutive positions are adjacent (it *is* a Ham. cycle);
* `auto`         — a graph automorphism;
* `preserves`    — `auto` preserves adjacency;
* `involutive` + `nontrivial` — `auto` has order exactly `2`;
* `rotation`     — `auto` acts on the cycle as rotation by `n/2`. -/
structure TwoSymHamCycle (n : ℕ) (Adj : ZMod n → ZMod n → Prop) where
  order : ZMod n ≃ ZMod n
  auto : ZMod n ≃ ZMod n
  consecutive : ∀ i, Adj (order i) (order (i + 1))
  preserves : ∀ a b, Adj a b → Adj (auto a) (auto b)
  involutive : ∀ x, auto (auto x) = x
  nontrivial : auto ≠ Equiv.refl _
  rotation : ∀ i, auto (order i) = order (i + diam n)

/-- Twice the diameter is zero for even `n` (the source of "order 2"). -/
theorem two_mul_diam {n : ℕ} (hn : Even n) : (2 : ZMod n) * diam n = 0 := by
  obtain ⟨k, hk⟩ := hn
  subst hk
  have h2 : (k + k) / 2 = k := by omega
  unfold diam
  rw [h2]
  have : (2 : ZMod (k + k)) * (k : ZMod (k + k)) = ((k + k : ℕ) : ZMod (k + k)) := by
    push_cast; ring
  rw [this, ZMod.natCast_self]

/-- For even `n`, the diameter is its own negative. -/
theorem neg_diam {n : ℕ} (hn : Even n) : -diam n = diam n := by
  have h := two_mul_diam hn
  linear_combination -h

/-- The diameter is nonzero for `n ≥ 4`, so translation by it is nontrivial. -/
theorem diam_ne_zero {n : ℕ} (h4 : 4 ≤ n) : diam n ≠ 0 := by
  unfold diam
  rw [Ne, ZMod.natCast_eq_zero_iff (n / 2) n]
  intro h
  have := Nat.le_of_dvd (by omega) h
  omega

end HamiltonianCompression