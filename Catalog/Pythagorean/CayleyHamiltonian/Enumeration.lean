import Mathlib

/-!
# Hamiltonian cycles from cyclic vertex enumerations

This file contains the combinatorial workhorse used in all our hamiltonicity results:
if the vertices of a finite graph `Γ` on `n ≥ 3` vertices can be listed in a cyclic order
`v 0, v 1, …, v (n-1)` such that consecutive vertices (cyclically) are adjacent, then `Γ`
is hamiltonian.

The enumeration is given as a function `v : ℕ → V` which is `n`-periodic and injective on
`{0, …, n-1}`; this "unrolled" form (rather than a function on `ZMod n` or `Fin n`) keeps
all index arithmetic inside `ℕ`, where `omega` can be used.

Main definitions and results:

* `CayleyHamiltonian.enumWalk` : the walk `v a → v (a+1) → ⋯ → v (a+k)`.
* `CayleyHamiltonian.isHamiltonian_of_enum` : the main theorem described above.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {V : Type*} {Γ : SimpleGraph V}

/-- The walk `v a → v (a+1) → ⋯ → v (a+k)` determined by a sequence of consecutive
adjacencies. -/
def enumWalk (Γ : SimpleGraph V) (v : ℕ → V) (hadj : ∀ i, Γ.Adj (v i) (v (i + 1))) (a : ℕ) :
    (k : ℕ) → Γ.Walk (v a) (v (a + k))
  | 0 => Walk.nil
  | (k + 1) => (enumWalk Γ v hadj a k).concat (hadj (a + k))

variable {v : ℕ → V} {hadj : ∀ i, Γ.Adj (v i) (v (i + 1))}

@[simp] lemma enumWalk_length (a k : ℕ) : (enumWalk Γ v hadj a k).length = k := by
  induction k with
  | zero => simp [enumWalk]
  | succ k ih => simp [enumWalk, ih]

lemma enumWalk_support (a k : ℕ) :
    (enumWalk Γ v hadj a k).support = (List.range (k + 1)).map (fun i => v (a + i)) := by
  induction k with
  | zero => simp [enumWalk]
  | succ k ih =>
      simp only [enumWalk, Walk.support_concat, ih, List.range_succ, List.map_append,
        List.concat_eq_append, List.map_cons, List.map_nil]

lemma enumWalk_edges (a k : ℕ) :
    (enumWalk Γ v hadj a k).edges
      = (List.range k).map (fun i => s(v (a + i), v (a + i + 1))) := by
  induction k with
  | zero => simp [enumWalk]
  | succ k ih =>
      simp only [enumWalk, Walk.edges_concat, ih, List.range_succ, List.map_append,
        List.concat_eq_append, List.map_cons, List.map_nil]
      rfl

/-- Periodicity of an enumeration reduces every index modulo the period. -/
lemma enum_periodic_mod {n : ℕ} (hn : 0 < n) (hper : ∀ i, v (i + n) = v i) (i : ℕ) :
    v i = v (i % n) := by
  induction i using Nat.strong_induction_on with
  | _ i ih =>
      rcases lt_or_ge i n with h | h
      · rw [Nat.mod_eq_of_lt h]
      · have hlt : i - n < i := by omega
        have hkey : v i = v (i - n) := by
          have hp := hper (i - n)
          rw [show i - n + n = i by omega] at hp
          exact hp
        have hik : i % n = (i - n) % n := by
          conv_lhs => rw [show i = (i - n) + n by omega]
          simp
        rw [hkey, ih _ hlt, hik]

/-- Two indices give the same vertex only if they are congruent modulo the period. -/
lemma enum_eq_iff_mod {n : ℕ} (hn : 0 < n) (hper : ∀ i, v (i + n) = v i)
    (hinj : ∀ i j, i < n → j < n → v i = v j → i = j) {i j : ℕ} (h : v i = v j) :
    i % n = j % n := by
  have h1 : v (i % n) = v (j % n) := by
    rw [← enum_periodic_mod hn hper i, ← enum_periodic_mod hn hper j]
    exact h
  exact hinj _ _ (Nat.mod_lt _ hn) (Nat.mod_lt _ hn) h1

/-- **Main combinatorial tool.**  A finite graph on `n ≥ 3` vertices admitting a cyclic
enumeration of its vertices along edges is hamiltonian. -/
theorem isHamiltonian_of_enum [Fintype V] [DecidableEq V] {n : ℕ} (hn : 3 ≤ n) (hcard : Fintype.card V = n)
    (v : ℕ → V) (hadj : ∀ i, Γ.Adj (v i) (v (i + 1)))
    (hinj : ∀ i j, i < n → j < n → v i = v j → i = j)
    (hper : ∀ i, v (i + n) = v i) :
    Γ.IsHamiltonian := by
  have hn0 : 0 < n := by omega
  -- the tail of the cycle: the path `v 1 → v 2 → ⋯ → v n = v 0`
  have hend : v (1 + (n - 1)) = v 0 := by
    have h1 : 1 + (n - 1) = 0 + n := by omega
    rw [h1]
    exact hper 0
  set P : Γ.Walk (v 1) (v (1 + (n - 1))) := enumWalk Γ v hadj 1 (n - 1) with hP
  set P' : Γ.Walk (v 1) (v 0) := P.copy rfl hend with hP'
  have hn1 : n - 1 + 1 = n := by omega
  have hsupp : P'.support = (List.range n).map (fun i => v (1 + i)) := by
    rw [hP', Walk.support_copy, hP, enumWalk_support, hn1]
  -- the enumeration is injective on `{0, …, n}`, up to the identification `v n = v 0`
  have hvn : v n = v 0 := by simpa using hper 0
  have key : ∀ i j : ℕ, i ≤ n → j ≤ n → v i = v j →
      i = j ∨ (i = 0 ∧ j = n) ∨ (i = n ∧ j = 0) := by
    intro i j hi hj h
    rcases eq_or_lt_of_le hi with hi' | hi'
    · subst hi'
      rcases eq_or_lt_of_le hj with hj' | hj'
      · exact Or.inl hj'.symm
      · have : v 0 = v j := by rw [← hvn]; exact h
        have := hinj 0 j hn0 hj' this
        exact Or.inr (Or.inr ⟨rfl, this.symm⟩)
    · rcases eq_or_lt_of_le hj with hj' | hj'
      · subst hj'
        have : v i = v 0 := by rw [← hvn]; exact h
        have := hinj i 0 hi' hn0 this
        exact Or.inr (Or.inl ⟨this, rfl⟩)
      · exact Or.inl (hinj i j hi' hj' h)
  -- `P'` is a path
  have hpath : P'.IsPath := by
    rw [Walk.isPath_def, hsupp]
    rw [List.nodup_map_iff_inj_on (List.nodup_range)]
    intro i hi j hj hij
    have hi' : i < n := by simpa using hi
    have hj' : j < n := by simpa using hj
    have hk := key (1 + i) (1 + j) (by omega) (by omega) hij
    omega
  -- the closing edge is not already used
  have hedge : s(v 0, v 1) ∉ P'.edges := by
    rw [hP', Walk.edges_copy, hP, enumWalk_edges]
    simp only [List.mem_map, List.mem_range, not_exists, not_and]
    intro i hi hcon
    rw [Sym2.eq_iff] at hcon
    rcases hcon with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
      · have k1 := key _ _ (by omega) (by omega) h1
        have k2 := key _ _ (by omega) (by omega) h2
        omega
  -- assemble the hamiltonian cycle
  have hadj01 : Γ.Adj (v 0) (v 1) := hadj 0
  refine fun _ => ⟨v 0, Walk.cons hadj01 P', ?_⟩
  rw [Walk.isHamiltonianCycle_iff_isCycle_and_length_eq]
  refine ⟨?_, ?_⟩
  · rw [Walk.cons_isCycle_iff]
    exact ⟨hpath, hedge⟩
  · rw [hcard]
    simp only [Walk.length_cons, hP', Walk.length_copy, hP, enumWalk_length]
    omega

end CayleyHamiltonian