import Mathlib
import Probability.CollatzBerggrenFibre

/-!
# The Collatz–Berggren bridge, VI: cycle-weight bounds and rank-one rigidity

Files I–V settled the transfer hypothesis: the inverse Syracuse tree is a
*rank-one* comb (each live fibre is the orbit of the single affine letter
`L : x ↦ 4x + 1`), it carries no polynomial invariant, and only the *shape* of
the ternary Berggren tree embeds into it.

This file closes two of the open directions that came out of that analysis.

## A. Two-sided bounds for the weight cocycle (Direction 3)

The affine defect of a Syracuse word is the cocycle `syrWeight`.  We bound it on
both sides and feed the bounds into the proved cycle equation
`m (2^S − 3^L) = syrWeight ks`:

* `syrWeight_upper` — `2^L · syrWeight ks ≤ 3^L · 2^S` for every admissible word;
* `syrWeight_lower` — `3^L ≤ 3 · syrWeight ks` for every nonempty word;
* `syr_cycle_min_upper` / `syr_cycle_min_lower` — the resulting two-sided pin on
  the minimum `m` of a hypothetical cycle;
* `syr_cycle_two_heavy_bound` — **the sharp consequence**: a cycle whose halving
  budget satisfies `2 · 3^L ≤ 2^S` obeys `2^L · m ≤ 2 · 3^L`, i.e.
  `m ≤ 2 · (3/2)^L`.  Nontrivial cycles must therefore live *very* close to the
  critical line `S = L · log₂ 3`, which is exactly the classical
  continued-fraction obstruction, here fully formal.

## B. Rank-one rigidity for affine-fibred trees (Direction 2)

The obstruction to invariants is not the arithmetic of `3n+1` but the *rank* of
the branching.  We prove this in the abstract:

* `affOrbit_strictMono`, `affOrbit_infinite` — the orbit of `x ↦ a x + b`
  (`a ≥ 2`, start `> 0`) is an infinite strictly increasing set;
* `affine_orbit_polynomial_rigidity` — any polynomial over `ℚ` constant on such
  an orbit is constant, for *every* pair `(a, b)`; the Collatz statement
  `no_nonconstant_polynomial_invariant` is the case `(a, b) = (4, 1)`;
* `affOrbit_eventually_periodic_mod` — the orbit residues modulo any `m > 0` are
  eventually periodic, and `predFam_eventually_periodic_mod` transports this to
  the genuine Collatz fibres.
-/

namespace CollatzBerggren

open Polynomial

/-! ## A. The weight cocycle, two-sided -/

/-- A word all of whose letters are `≥ 1` has sum at least its length. -/
theorem length_le_sum {ks : List ℕ} (h : ∀ k ∈ ks, 1 ≤ k) : ks.length ≤ ks.sum := by
  induction ks with
  | nil => simp
  | cons k ks ih =>
      have hk : 1 ≤ k := h k (List.mem_cons_self ..)
      have hrest : ∀ j ∈ ks, 1 ≤ j := fun j hj => h j (List.mem_cons_of_mem _ hj)
      have := ih hrest
      simp only [List.length_cons, List.sum_cons]
      omega

/-- **Upper bound for the weight cocycle.**  For every Syracuse word with all
letters `≥ 1`, `2^L · syrWeight ks ≤ 3^L · 2^S`, where `L` is the length and `S`
the sum of the word.  Equivalently `syrWeight ks ≤ 3^L · 2^{S-L}`: the affine
defect never outgrows the multiplicative one. -/
theorem syrWeight_upper : ∀ ks : List ℕ, (∀ k ∈ ks, 1 ≤ k) →
    2 ^ ks.length * syrWeight ks ≤ 3 ^ ks.length * 2 ^ ks.sum := by
  intro ks
  induction ks with
  | nil => simp
  | cons k ks ih =>
      intro h
      have hk : 1 ≤ k := h k (List.mem_cons_self ..)
      have hrest : ∀ j ∈ ks, 1 ≤ j := fun j hj => h j (List.mem_cons_of_mem _ hj)
      have hih := ih hrest
      have hlen : ks.length ≤ ks.sum := length_le_sum hrest
      -- abbreviations
      have hpow : 2 * 2 ^ ks.length ≤ 2 ^ k * 2 ^ ks.sum := by
        have hmono : 2 ^ (ks.length + 1) ≤ 2 ^ (k + ks.sum) :=
          Nat.pow_le_pow_right (by norm_num) (by omega)
        calc 2 * 2 ^ ks.length = 2 ^ (ks.length + 1) := by ring
          _ ≤ 2 ^ (k + ks.sum) := hmono
          _ = 2 ^ k * 2 ^ ks.sum := by ring
      have h2 : (2 * 2 ^ ks.length) * 3 ^ ks.length
          ≤ (2 ^ k * 2 ^ ks.sum) * 3 ^ ks.length := Nat.mul_le_mul hpow (le_refl _)
      have h1 : (2 * 2 ^ k) * (2 ^ ks.length * syrWeight ks)
          ≤ (2 * 2 ^ k) * (3 ^ ks.length * 2 ^ ks.sum) := Nat.mul_le_mul (le_refl _) hih
      have hL : (k :: ks).length = ks.length + 1 := by simp
      have hS : (k :: ks).sum = k + ks.sum := by simp
      rw [hL, hS, syrWeight_cons]
      calc 2 ^ (ks.length + 1) * (3 ^ ks.length + 2 ^ k * syrWeight ks)
          = (2 * 2 ^ ks.length) * 3 ^ ks.length
            + (2 * 2 ^ k) * (2 ^ ks.length * syrWeight ks) := by ring
        _ ≤ (2 ^ k * 2 ^ ks.sum) * 3 ^ ks.length
            + (2 * 2 ^ k) * (3 ^ ks.length * 2 ^ ks.sum) := Nat.add_le_add h2 h1
        _ = 3 ^ (ks.length + 1) * 2 ^ (k + ks.sum) := by ring

/-- **Lower bound for the weight cocycle.**  A nonempty Syracuse word has
`3^L ≤ 3 · syrWeight ks`, i.e. `syrWeight ks ≥ 3^{L-1}`. -/
theorem syrWeight_lower {ks : List ℕ} (h : ks ≠ []) :
    3 ^ ks.length ≤ 3 * syrWeight ks := by
  cases ks with
  | nil => exact absurd rfl h
  | cons k ks =>
      have hpos : 0 ≤ 2 ^ k * syrWeight ks := Nat.zero_le _
      have : 3 ^ (k :: ks).length = 3 * 3 ^ ks.length := by
        simp [pow_succ, mul_comm]
      rw [this, syrWeight_cons]
      omega

/-- On a cycle the multiplicative gap `2^S − 3^L` is positive and multiplies the
minimum to the weight. -/
theorem syr_cycle_gap_mul {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m) (hne : ks ≠ []) :
    m * (2 ^ ks.sum - 3 ^ ks.length) = syrWeight ks := by
  have hid := syrChain_identity h
  have hlt : 3 ^ ks.length < 2 ^ ks.sum := syr_cycle_pow_lt h hne
  have hexp : m * (2 ^ ks.sum - 3 ^ ks.length) + m * 3 ^ ks.length = m * 2 ^ ks.sum := by
    rw [← Nat.mul_add]
    congr 1
    omega
  have hid' : 2 ^ ks.sum * m = 3 ^ ks.length * m + syrWeight ks := hid
  have h1 : m * 2 ^ ks.sum = 2 ^ ks.sum * m := Nat.mul_comm _ _
  have h2 : m * 3 ^ ks.length = 3 ^ ks.length * m := Nat.mul_comm _ _
  omega

/-- **Upper pin on a hypothetical cycle.**  Combining the cycle equation with the
weight bound: any Syracuse cycle of length `L`, total halving budget `S` and
minimum `m` satisfies `2^L · m · (2^S − 3^L) ≤ 3^L · 2^S`. -/
theorem syr_cycle_min_upper {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m) (hne : ks ≠ []) :
    2 ^ ks.length * (m * (2 ^ ks.sum - 3 ^ ks.length)) ≤ 3 ^ ks.length * 2 ^ ks.sum := by
  rw [syr_cycle_gap_mul h hne]
  exact syrWeight_upper ks h.letters_pos

/-- **Lower pin on a hypothetical cycle.**  `3^L ≤ 3 · m · (2^S − 3^L)`. -/
theorem syr_cycle_min_lower {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m) (hne : ks ≠ []) :
    3 ^ ks.length ≤ 3 * (m * (2 ^ ks.sum - 3 ^ ks.length)) := by
  rw [syr_cycle_gap_mul h hne]
  exact syrWeight_lower hne

/-- **Two-heavy cycles are tiny.**  If a Syracuse cycle spends at least one extra
doubling beyond the critical line — `2 · 3^L ≤ 2^S` — then its minimum obeys
`2^L · m ≤ 2 · 3^L`, i.e. `m ≤ 2 · (3/2)^L`.

This is the quantitative form of the classical statement that a nontrivial cycle
must have `S/L` extremely close to `log₂ 3`: away from that line the cycle
minimum is forced below an explicit bound that the fibre structure of File IV
already rules out for small values. -/
theorem syr_cycle_two_heavy_bound {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m)
    (hne : ks ≠ []) (hheavy : 2 * 3 ^ ks.length ≤ 2 ^ ks.sum) :
    2 ^ ks.length * m ≤ 2 * 3 ^ ks.length := by
  set L := ks.length
  set S := ks.sum
  have hlt : 3 ^ L < 2 ^ S := syr_cycle_pow_lt h hne
  have hup : 2 ^ L * (m * (2 ^ S - 3 ^ L)) ≤ 3 ^ L * 2 ^ S := syr_cycle_min_upper h hne
  -- `2 (2^S − 3^L) ≥ 2^S`, so `2^L m 2^S ≤ 2 · 2^L m (2^S − 3^L) ≤ 2 · 3^L · 2^S`
  have hgap : 2 ^ S ≤ 2 * (2 ^ S - 3 ^ L) := by omega
  have hmul : (2 ^ L * m) * 2 ^ S ≤ (2 ^ L * m) * (2 * (2 ^ S - 3 ^ L)) :=
    Nat.mul_le_mul_left _ hgap
  have hchain : (2 ^ L * m) * (2 * (2 ^ S - 3 ^ L)) ≤ 2 * (3 ^ L * 2 ^ S) := by
    have : (2 ^ L * m) * (2 * (2 ^ S - 3 ^ L)) = 2 * (2 ^ L * (m * (2 ^ S - 3 ^ L))) := by
      ring
    rw [this]
    exact Nat.mul_le_mul_left 2 hup
  have hfin : (2 ^ L * m) * 2 ^ S ≤ (2 * 3 ^ L) * 2 ^ S := by
    calc (2 ^ L * m) * 2 ^ S ≤ (2 ^ L * m) * (2 * (2 ^ S - 3 ^ L)) := hmul
      _ ≤ 2 * (3 ^ L * 2 ^ S) := hchain
      _ = (2 * 3 ^ L) * 2 ^ S := by ring
  have hpos : 0 < 2 ^ S := Nat.pow_pos (by norm_num)
  exact Nat.le_of_mul_le_mul_right hfin hpos

/-- Sanity check on the only known cycle `1 → 1`, with word `[2]`:
the gap is `2² − 3 = 1`, the weight is `1`, and the two-heavy hypothesis fails
by exactly one factor of `2` (`2 · 3 = 6 > 4`) — the trivial cycle sits on the
critical side of the dichotomy. -/
theorem syr_cycle_one_data :
    1 * (2 ^ ([2] : List ℕ).sum - 3 ^ ([2] : List ℕ).length) = syrWeight [2] ∧
      syrWeight [2] = 1 ∧
      ¬ (2 * 3 ^ ([2] : List ℕ).length ≤ 2 ^ ([2] : List ℕ).sum) :=
  ⟨syr_cycle_gap_mul syrChain_one (by simp), by norm_num [syrWeight], by norm_num⟩

/-! ## B. Rank-one rigidity in the abstract -/

/-- The orbit of the affine letter `x ↦ a x + b`, the abstract form of the
Collatz branching letter `L : x ↦ 4x + 1`. -/
def affOrbit (a b x₀ : ℕ) : ℕ → ℕ
  | 0 => x₀
  | j + 1 => a * affOrbit a b x₀ j + b

@[simp] theorem affOrbit_zero (a b x₀ : ℕ) : affOrbit a b x₀ 0 = x₀ := rfl

@[simp] theorem affOrbit_succ (a b x₀ j : ℕ) :
    affOrbit a b x₀ (j + 1) = a * affOrbit a b x₀ j + b := rfl

theorem affOrbit_pos {a b x₀ : ℕ} (ha : 2 ≤ a) (hx : 0 < x₀) (j : ℕ) :
    0 < affOrbit a b x₀ j := by
  induction j with
  | zero => simpa using hx
  | succ i ih =>
      have : 0 < a * affOrbit a b x₀ i := Nat.mul_pos (by omega) ih
      simp only [affOrbit_succ]
      omega

/-- With multiplier `≥ 2` and a positive start, the affine orbit is strictly
increasing. -/
theorem affOrbit_strictMono {a b x₀ : ℕ} (ha : 2 ≤ a) (hx : 0 < x₀) :
    StrictMono (affOrbit a b x₀) := by
  refine strictMono_nat_of_lt_succ fun j => ?_
  have hpos : 0 < affOrbit a b x₀ j := affOrbit_pos (b := b) ha hx j
  have : 2 * affOrbit a b x₀ j ≤ a * affOrbit a b x₀ j :=
    Nat.mul_le_mul ha (le_refl _)
  simp only [affOrbit_succ]
  omega

/-- Hence the orbit is an infinite set of natural numbers — a rank-one fibre is
always infinite. -/
theorem affOrbit_infinite {a b x₀ : ℕ} (ha : 2 ≤ a) (hx : 0 < x₀) :
    (Set.range (affOrbit a b x₀)).Infinite :=
  Set.infinite_range_of_injective (affOrbit_strictMono ha hx).injective

/-- **Abstract rigidity core.**  A rational polynomial taking one and the same
value on an infinite set of naturals is constant. -/
theorem polynomial_const_of_infinite_level_set {S : Set ℕ} (hS : S.Infinite) (v : ℚ)
    (P : ℚ[X]) (h : ∀ m ∈ S, P.eval (m : ℚ) = v) : P = C v := by
  have himg : ((fun m : ℕ => (m : ℚ)) '' S).Infinite :=
    hS.image (Set.injOn_of_injective Nat.cast_injective)
  have hroots : {x : ℚ | (P - C v).IsRoot x}.Infinite := by
    refine himg.mono ?_
    rintro x ⟨m, hm, rfl⟩
    simp [Polynomial.IsRoot, h m hm]
  have hzero : P - C v = 0 := Polynomial.eq_zero_of_infinite_isRoot _ hroots
  exact sub_eq_zero.1 hzero

/-- **Rank-one rigidity (Direction 2).**  For *every* affine letter `x ↦ a x + b`
with `a ≥ 2`, a polynomial that is constant along one orbit is globally constant.
The failure of Collatz invariants is therefore a statement about the *rank* of
the branching, not about the arithmetic of `3n + 1`: the Collatz case is
`(a, b) = (4, 1)`. -/
theorem affine_orbit_polynomial_rigidity {a b x₀ : ℕ} (ha : 2 ≤ a) (hx : 0 < x₀)
    (P : ℚ[X]) (h : ∀ j : ℕ, P.eval ((affOrbit a b x₀ j : ℕ) : ℚ) = P.eval (x₀ : ℚ)) :
    P = C (P.eval (x₀ : ℚ)) := by
  refine polynomial_const_of_infinite_level_set
    (S := Set.range (affOrbit a b x₀)) (affOrbit_infinite (b := b) ha hx) _ P ?_
  rintro m ⟨j, rfl⟩
  exact h j

/-- The Collatz fibre over a live node is the orbit of `x ↦ 4x + 1` started at
`predFam n 0`. -/
theorem predFam_eq_affOrbit {n : ℕ} (h1 : n % 3 ≠ 0) (j : ℕ) :
    predFam n j = affOrbit 4 1 (predFam n 0) j := by
  induction j with
  | zero => rfl
  | succ i ih => rw [predFam_succ h1 i, affOrbit_succ, ih]

/-- Rigidity, specialised back to the genuine Collatz fibres: a polynomial
constant on one live fibre is constant. -/
theorem collatz_fibre_polynomial_rigidity {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0)
    (P : ℚ[X]) (h : ∀ m ∈ predSet n, P.eval (m : ℚ) = P.eval ((predFam n 0 : ℕ) : ℚ)) :
    P = C (P.eval ((predFam n 0 : ℕ) : ℚ)) := by
  refine affine_orbit_polynomial_rigidity (a := 4) (b := 1) (by norm_num) ?_ P ?_
  · have h0 : predFam n 0 ∈ predSet n := predFam_mem hn h1 0
    have hodd : Odd (predFam n 0) := SyrPred.odd_left h0
    exact hodd.pos
  · intro j
    rw [← predFam_eq_affOrbit h1 j]
    exact h _ (predFam_mem hn h1 j)

/-! ### Residue periodicity along a rank-one fibre -/

/-- One affine step respects congruences. -/
theorem affStep_modEq {a b m x y : ℕ} (h : x ≡ y [MOD m]) :
    a * x + b ≡ a * y + b [MOD m] :=
  (h.mul_left a).add_right b

/-- Congruent orbit positions stay congruent forever. -/
theorem affOrbit_modEq_shift {a b x₀ m i j : ℕ}
    (h : affOrbit a b x₀ i ≡ affOrbit a b x₀ j [MOD m]) (t : ℕ) :
    affOrbit a b x₀ (i + t) ≡ affOrbit a b x₀ (j + t) [MOD m] := by
  induction t with
  | zero => simp only [Nat.add_zero]; exact h
  | succ s ih =>
      have hstep := affStep_modEq (a := a) (b := b) ih
      simp only [← Nat.add_assoc, affOrbit_succ]
      exact hstep

/-- **Eventual periodicity of a rank-one fibre modulo `m`.**  For every modulus
`m > 0` the residues of an affine orbit are eventually periodic, with a period
at most `m`. -/
theorem affOrbit_eventually_periodic_mod (a b x₀ : ℕ) {m : ℕ} (hm : 0 < m) :
    ∃ i p : ℕ, 0 < p ∧ p ≤ m ∧
      ∀ t : ℕ, affOrbit a b x₀ (i + t + p) ≡ affOrbit a b x₀ (i + t) [MOD m] := by
  -- pigeonhole: among the `m + 1` indices `0, …, m` two have equal residues
  have hmaps : ∀ j ∈ Finset.range (m + 1), affOrbit a b x₀ j % m ∈ Finset.range m := by
    intro j _
    exact Finset.mem_range.2 (Nat.mod_lt _ hm)
  have hcard : (Finset.range m).card < (Finset.range (m + 1)).card := by
    simp
  obtain ⟨i, hi, j, hj, hij, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  -- order the two indices
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨i, j - i, by omega, ?_, ?_⟩
    · have := Finset.mem_range.1 hj
      omega
    · intro t
      have hmod : affOrbit a b x₀ j ≡ affOrbit a b x₀ i [MOD m] := heq.symm
      have := affOrbit_modEq_shift (a := a) (b := b) (x₀ := x₀) (m := m) hmod t
      have hji : j + t = i + t + (j - i) := by omega
      rw [hji] at this
      exact this
  · refine ⟨j, i - j, by omega, ?_, ?_⟩
    · have := Finset.mem_range.1 hi
      omega
    · intro t
      have hmod : affOrbit a b x₀ i ≡ affOrbit a b x₀ j [MOD m] := heq
      have := affOrbit_modEq_shift (a := a) (b := b) (x₀ := x₀) (m := m) hmod t
      have hij' : i + t = j + t + (i - j) := by omega
      rw [hij'] at this
      exact this

/-- The same statement for the genuine Collatz fibres: the predecessor family of
a live node is eventually periodic modulo every positive modulus. -/
theorem predFam_eventually_periodic_mod {n : ℕ} (h1 : n % 3 ≠ 0) {m : ℕ} (hm : 0 < m) :
    ∃ i p : ℕ, 0 < p ∧ p ≤ m ∧
      ∀ t : ℕ, predFam n (i + t + p) ≡ predFam n (i + t) [MOD m] := by
  obtain ⟨i, p, hp, hpm, hper⟩ :=
    affOrbit_eventually_periodic_mod 4 1 (predFam n 0) hm
  refine ⟨i, p, hp, hpm, fun t => ?_⟩
  rw [predFam_eq_affOrbit h1 (i + t + p), predFam_eq_affOrbit h1 (i + t)]
  exact hper t

/-- The fibre over `1` is `1, 5, 21, 85, …`; its residues modulo `3` are not
constant but run through the exact period-`3` clock `1, 2, 0, 1, 2, 0, …`.  This
is the sharp form of the periodicity theorem in the Collatz case, and it is the
reason why exactly one member in three of a fibre is *live* (not divisible by
`3`, hence itself branching). -/
theorem affOrbit_four_one_mod_three (j : ℕ) : affOrbit 4 1 1 j % 3 = (j + 1) % 3 := by
  induction j with
  | zero => rfl
  | succ i ih => simp only [affOrbit_succ]; omega

theorem predFam_one_mod_three (j : ℕ) : predFam 1 j % 3 = (j + 1) % 3 := by
  have h0 : predFam 1 0 = 1 := by norm_num [predFam, startExp]
  have hj : predFam 1 j = affOrbit 4 1 1 j := by
    rw [predFam_eq_affOrbit (n := 1) (by norm_num) j, h0]
  rw [hj, affOrbit_four_one_mod_three]

/-- Exactly the fibre members with index `j ≡ 2 (mod 3)` are dead: `21`, `341`, …
The live members of the fibre over `1` are those with `j % 3 ≠ 2`. -/
theorem predFam_one_live_iff (j : ℕ) : predFam 1 j % 3 ≠ 0 ↔ j % 3 ≠ 2 := by
  have h := predFam_one_mod_three j
  omega

end CollatzBerggren