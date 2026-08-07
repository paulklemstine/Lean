/-
# The Converse of Kraft's Inequality and the Shannon Coding Theorem for Proof Descriptions

The previous cycle of the "Proof Complexity and Thermodynamic Cost" thread proved, in
`Catalog/Computation/PrefixFreeThermoCoding.lean`, the *necessity* half of the prefix-free
ensemble refinement: a prefix-free set of proof descriptions satisfies Kraft's inequality,
hence its expected length is at least the Shannon entropy of the theorem ensemble, with
equality exactly for complete dyadic codes.  What was missing — and what Future Direction C
of that cycle isolated — is the *sufficiency* half: that Kraft-admissible lengths are actually
realised by a prefix-free code.  Without it, `shannon_fano_lengths` produces a length
function, not a code, and the Landauer floor is not known to be approachable by any real
description scheme.

This file supplies the missing half, constructively, and then closes the loop.

## Main results

* `eq_shift_of_prefix` — the arithmetic meaning of the prefix relation on big-endian binary
  words: `bits k a <+: bits m b ↔ a` is the top `k` bits of `b`.
* `kraft_converse` — **converse of Kraft's inequality**: for any length function `ℓ` on a
  finite ensemble with `∑ 2^{-ℓ i} ≤ 1` there is an *injective* code `c` with
  `|c i| = ℓ i` whose image is prefix-free.  The construction is the classical
  "cumulative dyadic interval" code, made explicit: sort the lengths, and give theorem `i`
  the big-endian binary expansion of the partial Kraft sum `∑_{j<i} 2^{L-ℓ j}`.
* `kraft_realisable_iff` — combining with `kraftSum_le_one_of_prefixFree_code`, the Kraft
  inequality is *exactly* the realisability criterion for prefix-free proof codes.
* `shannon_source_coding` — the full source-coding theorem for theorem ensembles: there is a
  genuine prefix-free code whose expected description length lies in `[H(p), H(p)+1)`.
* `exists_complete_code_of_dyadic` — for a dyadic ensemble the entropy floor is *attained* by
  an explicit complete prefix code (Kraft sum exactly `1`).
* `landauer_floor_attainable`, `landauer_floor_within_one_bit` — the thermodynamic readings:
  the entropy floor on expected Landauer cost of erasing proof descriptions is attained for
  dyadic ensembles, and approached to within one Landauer quantum `k_B T ln 2` in general.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the counting proof of Kraft (cylinders inside `2^L` words) should be
  reversible: if the cylinder volumes fit inside `[0, 2^L)`, one can simply *pack* them
  left to right, and the packing is prefix-free because the resulting dyadic intervals are
  disjoint.  The only obstruction is alignment: interval `i` must start at a multiple of its
  own length, which is exactly what sorting the lengths guarantees.
Experiment (Stage 2): formalised big-endian words `bits k a`, proved
  `(bits m b).take k = bits k (b / 2^(m-k))`, and turned the prefix relation into the
  arithmetic statement `a = b / 2^(m-k)`.  The packing map is
  `i ↦ bits (ℓ i) ((∑_{j<i} 2^{L-ℓ j}) / 2^{L-ℓ i})`.  Sorting is imported from
  `Tuple.sort`, and the general finite index type is reduced to `Fin n` by that permutation.
Analysis (Stage 3): monotonicity of the lengths is load-bearing twice — for the divisibility
  `2^{L-ℓ i} ∣ ∑_{j<i} 2^{L-ℓ j}` (alignment) and nowhere else; disjointness of the intervals
  is automatic from the partial sums.  Without sorting the construction genuinely fails: at
  depth `L = 2` the unsorted profile `(2,1)` produces the words `00` and `0` (the second block
  starts at the misaligned position `1`), and `0` is a prefix of `00`.
Critique (Stage 4): the theorem is stated with *injectivity* of the code as an explicit
  conjunct, since prefix-freeness of the image alone would be vacuous for a constant code;
  and `kraft_realisable_iff` is stated as a genuine equivalence to rule out a one-sided
  reading.  All statements quantify over an arbitrary finite ensemble, not just `Fin n`.
Synthesis (Stage 5): Kraft's inequality is a *characterisation* of realisable proof-code
  length profiles, so the entropy lower bound on expected Landauer cost is sharp: it is
  attained for dyadic theorem ensembles and approached within one quantum in general.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.PrefixFreeThermoCoding

open Finset Real ThermoProof PrefixFreeThermo

namespace KraftConverse

/-! ## Big-endian binary words -/

/-- The little-endian list of the low `k` bits of `a`. -/
def bitsRev : ℕ → ℕ → List Bool
  | 0, _ => []
  | k + 1, a => (a % 2 == 1) :: bitsRev k (a / 2)

/-- The big-endian binary word of length `k` representing `a` (mod `2^k`). -/
def bits (k a : ℕ) : List Bool := (bitsRev k a).reverse

@[simp] lemma length_bitsRev (k a : ℕ) : (bitsRev k a).length = k := by
  induction k generalizing a with
  | zero => simp [bitsRev]
  | succ k ih => simp [bitsRev, ih]

@[simp] lemma length_bits (k a : ℕ) : (bits k a).length = k := by simp [bits]

lemma bitsRev_drop (t : ℕ) :
    ∀ m a : ℕ, (bitsRev m a).drop t = bitsRev (m - t) (a / 2 ^ t) := by
  induction t with
  | zero => intro m a; simp
  | succ t ih =>
    intro m a
    cases m with
    | zero => simp [bitsRev]
    | succ m =>
      have h1 : m + 1 - (t + 1) = m - t := by omega
      have h2 : a / 2 ^ (t + 1) = a / 2 / 2 ^ t := by
        rw [Nat.div_div_eq_div_mul, pow_succ, mul_comm]
      rw [h1, h2, bitsRev, List.drop_succ_cons, ih m (a / 2)]

lemma bitsRev_inj {k a b : ℕ} (ha : a < 2 ^ k) (hb : b < 2 ^ k)
    (h : bitsRev k a = bitsRev k b) : a = b := by
  induction k generalizing a b with
  | zero => simp at ha hb; omega
  | succ k ih =>
    rw [bitsRev, bitsRev, List.cons.injEq] at h
    have h1 : a % 2 = b % 2 := by
      have hb2 := h.1
      rcases Nat.mod_two_eq_zero_or_one a with e1 | e1 <;>
        rcases Nat.mod_two_eq_zero_or_one b with e2 | e2 <;> simp [e1, e2] at hb2 ⊢
    have h2 : a / 2 = b / 2 :=
      ih (by rw [pow_succ] at ha; omega) (by rw [pow_succ] at hb; omega) h.2
    omega

lemma bits_inj {k a b : ℕ} (ha : a < 2 ^ k) (hb : b < 2 ^ k) (h : bits k a = bits k b) :
    a = b :=
  bitsRev_inj ha hb (by simpa [bits] using congrArg List.reverse h)

lemma take_bits {k m a : ℕ} (h : k ≤ m) : (bits m a).take k = bits k (a / 2 ^ (m - k)) := by
  have hk : m - (m - k) = k := by omega
  rw [bits, List.take_reverse, length_bitsRev, bitsRev_drop, hk, bits]

/-- **Arithmetic meaning of the prefix relation.**  A big-endian word of length `k` is a
prefix of one of length `m` exactly when it encodes the top `k` bits. -/
lemma eq_shift_of_prefix {k m a b : ℕ} (ha : a < 2 ^ k) (hb : b < 2 ^ m)
    (hpre : bits k a <+: bits m b) : a = b / 2 ^ (m - k) := by
  have hkm : k ≤ m := by simpa using hpre.length_le
  have htake : bits k a = (bits m b).take k := by
    rw [List.prefix_iff_eq_take] at hpre
    simpa using hpre
  rw [take_bits hkm] at htake
  refine bits_inj ha ?_ htake
  rw [Nat.div_lt_iff_lt_mul (by positivity), ← pow_add]
  have h : k + (m - k) = m := by omega
  rw [h]; exact hb

/-! ## The packing construction -/

/-- Partial Kraft sum at depth `L`: the left endpoint of the dyadic interval allotted to
theorem `i`. -/
def pref (L : ℕ) (ℓ : ℕ → ℕ) (i : ℕ) : ℕ := ∑ j ∈ Finset.range i, 2 ^ (L - ℓ j)

/-- The codeword allotted to index `i`: the big-endian name of its dyadic interval. -/
def word (L : ℕ) (ℓ : ℕ → ℕ) (i : ℕ) : List Bool := bits (ℓ i) (pref L ℓ i / 2 ^ (L - ℓ i))

@[simp] lemma length_word (L ℓ i) : (word L ℓ i).length = ℓ i := by simp [word]

lemma pref_succ (L ℓ i) : pref L ℓ (i + 1) = pref L ℓ i + 2 ^ (L - ℓ i) := by
  simp [pref, Finset.sum_range_succ]

lemma pref_mono (L ℓ) {i j : ℕ} (h : i ≤ j) : pref L ℓ i ≤ pref L ℓ j := by
  apply Finset.sum_le_sum_of_subset
  exact Finset.range_subset_range.2 h

/-- **Alignment.**  Because the lengths are sorted, every partial sum is a multiple of the
block size it precedes — this is what makes the packing expressible as a binary word. -/
lemma pref_dvd (L : ℕ) (ℓ : ℕ → ℕ) {n i : ℕ} (hi : i < n)
    (hmono : ∀ a b, a ≤ b → b < n → ℓ a ≤ ℓ b) : 2 ^ (L - ℓ i) ∣ pref L ℓ i := by
  refine Finset.dvd_sum ?_
  intro j hj
  simp only [Finset.mem_range] at hj
  exact pow_dvd_pow 2 (by have := hmono j i (le_of_lt hj) hi; omega)

lemma pref_add_le (L : ℕ) (ℓ : ℕ → ℕ) {n i : ℕ} (hi : i < n) (hk : pref L ℓ n ≤ 2 ^ L) :
    pref L ℓ i + 2 ^ (L - ℓ i) ≤ 2 ^ L :=
  calc pref L ℓ i + 2 ^ (L - ℓ i) = pref L ℓ (i + 1) := (pref_succ L ℓ i).symm
    _ ≤ pref L ℓ n := pref_mono L ℓ hi
    _ ≤ 2 ^ L := hk

lemma pref_div_lt (L : ℕ) (ℓ : ℕ → ℕ) {n i : ℕ} (hi : i < n) (hL : ℓ i ≤ L)
    (hk : pref L ℓ n ≤ 2 ^ L) : pref L ℓ i / 2 ^ (L - ℓ i) < 2 ^ ℓ i := by
  have h1 := pref_add_le L ℓ hi hk
  have h2 : (0 : ℕ) < 2 ^ (L - ℓ i) := by positivity
  rw [Nat.div_lt_iff_lt_mul h2, ← pow_add]
  have h3 : ℓ i + (L - ℓ i) = L := by omega
  rw [h3]
  omega

/-- **Disjointness of the allotted intervals is prefix-freeness of the code.**  If one
codeword is a prefix of another then the two indices coincide. -/
lemma word_prefix_eq (L : ℕ) (ℓ : ℕ → ℕ) {n : ℕ}
    (hmono : ∀ a b, a ≤ b → b < n → ℓ a ≤ ℓ b) (hL : ∀ i, i < n → ℓ i ≤ L)
    (hk : pref L ℓ n ≤ 2 ^ L) {i j : ℕ} (hi : i < n) (hj : j < n)
    (hpre : word L ℓ i <+: word L ℓ j) : i = j := by
  have hkm : ℓ i ≤ ℓ j := by simpa using hpre.length_le
  have hiL : ℓ i ≤ L := hL i hi
  have hjL : ℓ j ≤ L := hL j hj
  have ha : pref L ℓ i / 2 ^ (L - ℓ i) < 2 ^ ℓ i := pref_div_lt L ℓ hi hiL hk
  have hb : pref L ℓ j / 2 ^ (L - ℓ j) < 2 ^ ℓ j := pref_div_lt L ℓ hj hjL hk
  have heq : pref L ℓ i / 2 ^ (L - ℓ i)
      = (pref L ℓ j / 2 ^ (L - ℓ j)) / 2 ^ (ℓ j - ℓ i) := eq_shift_of_prefix ha hb hpre
  set a := pref L ℓ i / 2 ^ (L - ℓ i) with hadef
  set b := pref L ℓ j / 2 ^ (L - ℓ j) with hbdef
  have hdi : pref L ℓ i = a * 2 ^ (L - ℓ i) :=
    (Nat.div_mul_cancel (pref_dvd L ℓ hi hmono)).symm
  have hdj : pref L ℓ j = b * 2 ^ (L - ℓ j) :=
    (Nat.div_mul_cancel (pref_dvd L ℓ hj hmono)).symm
  -- write `b` as `2^(ℓ j − ℓ i) * a + r`
  set r := b % 2 ^ (ℓ j - ℓ i) with hrdef
  have hbr : b = 2 ^ (ℓ j - ℓ i) * a + r := by
    rw [heq, hrdef]
    exact (Nat.div_add_mod b (2 ^ (ℓ j - ℓ i))).symm
  have hrlt : r < 2 ^ (ℓ j - ℓ i) := Nat.mod_lt _ (Nat.two_pow_pos _)
  have hpow : 2 ^ (ℓ j - ℓ i) * 2 ^ (L - ℓ j) = 2 ^ (L - ℓ i) := by
    rw [← pow_add]; congr 1; omega
  have h1 : pref L ℓ j = pref L ℓ i + r * 2 ^ (L - ℓ j) := by
    rw [hdj, hdi]
    calc b * 2 ^ (L - ℓ j)
        = a * (2 ^ (ℓ j - ℓ i) * 2 ^ (L - ℓ j)) + r * 2 ^ (L - ℓ j) := by
          rw [hbr]; ring
      _ = a * 2 ^ (L - ℓ i) + r * 2 ^ (L - ℓ j) := by rw [hpow]
  have h2 : r * 2 ^ (L - ℓ j) < 2 ^ (L - ℓ i) := by
    calc r * 2 ^ (L - ℓ j) < 2 ^ (ℓ j - ℓ i) * 2 ^ (L - ℓ j) :=
          Nat.mul_lt_mul_of_lt_of_le hrlt (le_refl _) (Nat.two_pow_pos _)
      _ = 2 ^ (L - ℓ i) := hpow
  by_contra hne
  rcases Nat.lt_or_ge i j with h | h
  · have hstep := pref_mono L ℓ (Nat.succ_le_of_lt h)
    rw [pref_succ] at hstep
    linarith [hstep, h1, h2]
  · have hji : j < i := by omega
    have hstep := pref_mono L ℓ (Nat.succ_le_of_lt hji)
    rw [pref_succ] at hstep
    linarith [hstep, h1, Nat.two_pow_pos (L - ℓ j), Nat.zero_le (r * 2 ^ (L - ℓ j))]

/-! ## Kraft's converse -/

/-- Real-to-integer form of Kraft's inequality: a Kraft sum `≤ 1` means the dyadic blocks
fit inside `[0, 2^L)`. -/
lemma pref_le_of_kraft {n L : ℕ} {ℓ : ℕ → ℕ} (hL : ∀ i, i < n → ℓ i ≤ L)
    (hk : ∑ i ∈ Finset.range n, ((2 : ℝ)⁻¹) ^ ℓ i ≤ 1) : pref L ℓ n ≤ 2 ^ L := by
  have hcast : ((pref L ℓ n : ℕ) : ℝ) ≤ ((2 ^ L : ℕ) : ℝ) := by
    have hterm : ∀ i ∈ Finset.range n,
        ((2 : ℝ) ^ (L - ℓ i)) = 2 ^ L * ((2 : ℝ)⁻¹) ^ ℓ i := by
      intro i hi
      simp only [Finset.mem_range] at hi
      have h : ℓ i + (L - ℓ i) = L := by have := hL i hi; omega
      have h2 : (2 : ℝ) ^ L = 2 ^ ℓ i * 2 ^ (L - ℓ i) := by rw [← pow_add, h]
      rw [h2, inv_pow]
      field_simp
    have : ((pref L ℓ n : ℕ) : ℝ) = ∑ i ∈ Finset.range n, (2 : ℝ) ^ (L - ℓ i) := by
      simp [pref]
    rw [this, Finset.sum_congr rfl hterm, ← Finset.mul_sum]
    push_cast
    nlinarith [hk, pow_pos (by norm_num : (0:ℝ) < 2) L]
  exact_mod_cast hcast

/-- **Converse of Kraft's inequality.**  Every Kraft-admissible length profile on a finite
ensemble of theorems is realised by an injective prefix-free code.  Together with
`PrefixFreeThermo.kraftSum_le_one_of_prefixFree_code` this makes Kraft's inequality the exact
criterion for the existence of a prefix-free proof-description scheme. -/
theorem kraft_converse {ι : Type*} [Fintype ι] [DecidableEq ι] (ℓ : ι → ℕ)
    (hk : kraftSum ℓ ≤ 1) :
    ∃ c : ι → List Bool, Function.Injective c ∧ (∀ i, (c i).length = ℓ i) ∧
      PrefixFree (Finset.univ.image c) := by
  classical
  set n := Fintype.card ι with hn
  -- a length-sorted enumeration of the ensemble
  obtain ⟨g, hg⟩ : ∃ g : Fin n ≃ ι, Monotone (ℓ ∘ g) := by
    refine ⟨(Tuple.sort (ℓ ∘ (Fintype.equivFin ι).symm)).trans (Fintype.equivFin ι).symm, ?_⟩
    exact Tuple.monotone_sort (ℓ ∘ (Fintype.equivFin ι).symm)
  set ℓ' : ℕ → ℕ := fun k => if h : k < n then ℓ (g ⟨k, h⟩) else 0 with hℓ'
  set L : ℕ := Finset.univ.sup ℓ with hLdef
  have hℓ'_eq : ∀ (k : Fin n), ℓ' (k : ℕ) = ℓ (g k) := by
    intro k
    simp only [hℓ', dif_pos k.isLt]
  have hL : ∀ i, i < n → ℓ' i ≤ L := by
    intro i hi
    rw [show ℓ' i = ℓ (g ⟨i, hi⟩) from hℓ'_eq ⟨i, hi⟩]
    exact Finset.le_sup (f := ℓ) (Finset.mem_univ _)
  have hmono : ∀ a b, a ≤ b → b < n → ℓ' a ≤ ℓ' b := by
    intro a b hab hb
    have ha : a < n := lt_of_le_of_lt hab hb
    rw [show ℓ' a = ℓ (g ⟨a, ha⟩) from hℓ'_eq ⟨a, ha⟩,
      show ℓ' b = ℓ (g ⟨b, hb⟩) from hℓ'_eq ⟨b, hb⟩]
    exact hg (by simpa [Fin.le_def] using hab)
  have hkr : ∑ i ∈ Finset.range n, ((2 : ℝ)⁻¹) ^ ℓ' i ≤ 1 := by
    have h1 : ∑ i ∈ Finset.range n, ((2 : ℝ)⁻¹) ^ ℓ' i
        = ∑ k : Fin n, ((2 : ℝ)⁻¹) ^ ℓ' (k : ℕ) :=
      (Fin.sum_univ_eq_sum_range (fun i => ((2 : ℝ)⁻¹) ^ ℓ' i) n).symm
    have h2 : ∑ k : Fin n, ((2 : ℝ)⁻¹) ^ ℓ' (k : ℕ) = ∑ k : Fin n, ((2 : ℝ)⁻¹) ^ ℓ (g k) :=
      Finset.sum_congr rfl fun k _ => by rw [hℓ'_eq k]
    have h3 : ∑ k : Fin n, ((2 : ℝ)⁻¹) ^ ℓ (g k) = ∑ i : ι, ((2 : ℝ)⁻¹) ^ ℓ i :=
      Equiv.sum_comp g (fun i => ((2 : ℝ)⁻¹) ^ ℓ i)
    rw [h1, h2, h3]
    exact hk
  have hpk : pref L ℓ' n ≤ 2 ^ L := pref_le_of_kraft hL hkr
  refine ⟨fun i => word L ℓ' (g.symm i : ℕ), ?_, ?_, ?_⟩
  · -- injectivity
    intro i j hij
    have hij' : word L ℓ' (g.symm i : ℕ) = word L ℓ' (g.symm j : ℕ) := hij
    have := word_prefix_eq L ℓ' hmono hL hpk (g.symm i).isLt (g.symm j).isLt
      (hij' ▸ List.prefix_rfl)
    have : (g.symm i : Fin n) = g.symm j := Fin.ext this
    exact g.symm.injective this
  · intro i
    rw [length_word, hℓ'_eq (g.symm i), Equiv.apply_symm_apply]
  · intro u hu v hv huv
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hu hv
    obtain ⟨i, rfl⟩ := hu
    obtain ⟨j, rfl⟩ := hv
    have := word_prefix_eq L ℓ' hmono hL hpk (g.symm i).isLt (g.symm j).isLt huv
    rw [this]

/-- **Kraft's inequality is exactly the realisability criterion** for prefix-free proof
codes: a length profile is realised by an injective prefix-free code iff its Kraft sum is at
most one. -/
theorem kraft_realisable_iff {ι : Type*} [Fintype ι] [DecidableEq ι] (ℓ : ι → ℕ) :
    (∃ c : ι → List Bool, Function.Injective c ∧ (∀ i, (c i).length = ℓ i) ∧
      PrefixFree (Finset.univ.image c)) ↔ kraftSum ℓ ≤ 1 := by
  constructor
  · rintro ⟨c, hinj, hlen, hpf⟩
    have := kraftSum_le_one_of_prefixFree_code c hinj hpf
    have hcong : kraftSum (fun i => (c i).length) = kraftSum ℓ :=
      Finset.sum_congr rfl fun i _ => by simp only [hlen i]
    rwa [hcong] at this
  · exact kraft_converse ℓ

/-! ## The source-coding theorem for theorem ensembles -/

/-- **Shannon's source-coding theorem for proof descriptions.**  For every theorem ensemble
with strictly positive probabilities there is a genuine *prefix-free* description scheme
whose expected description length lies in `[H(p), H(p) + 1)`.  The lower bound is
`shannon_entropy_lower_bound`; the upper bound needs the converse of Kraft, since it is what
turns the Shannon–Fano *lengths* into an actual code. -/
theorem shannon_source_coding {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1) :
    ∃ c : ι → List Bool, Function.Injective c ∧ PrefixFree (Finset.univ.image c) ∧
      entropy p ≤ expectedLength p (fun i => (c i).length) ∧
      expectedLength p (fun i => (c i).length) < entropy p + 1 := by
  obtain ⟨ℓ, hkraft, hlow, hhigh⟩ := optimal_expected_length_bounds p hp hsum
  obtain ⟨c, hinj, hlen, hpf⟩ := kraft_converse ℓ hkraft
  have hcong : expectedLength p (fun i => (c i).length) = expectedLength p ℓ :=
    Finset.sum_congr rfl fun i _ => by simp only [hlen i]
  exact ⟨c, hinj, hpf, by rw [hcong]; exact hlow, by rw [hcong]; exact hhigh⟩

/-- **The entropy floor is attained for dyadic ensembles.**  If every theorem probability is
a power of `1/2`, there is a complete prefix code (Kraft sum exactly `1`) whose expected
description length equals the Shannon entropy. -/
theorem exists_complete_code_of_dyadic {ι : Type*} [Fintype ι] [DecidableEq ι]
    (p : ι → ℝ) (hsum : ∑ i, p i = 1) (ℓ : ι → ℕ)
    (hdy : ∀ i, p i = ((2 : ℝ)⁻¹) ^ ℓ i) :
    ∃ c : ι → List Bool, Function.Injective c ∧ PrefixFree (Finset.univ.image c) ∧
      kraftSum (fun i => (c i).length) = 1 ∧
      expectedLength p (fun i => (c i).length) = entropy p := by
  have hk : kraftSum ℓ = 1 := by
    unfold kraftSum
    rw [← hsum]
    exact Finset.sum_congr rfl fun i _ => (hdy i).symm
  obtain ⟨c, hinj, hlen, hpf⟩ := kraft_converse ℓ (le_of_eq hk)
  have hcongk : kraftSum (fun i => (c i).length) = kraftSum ℓ :=
    Finset.sum_congr rfl fun i _ => by simp only [hlen i]
  have hcongE : expectedLength p (fun i => (c i).length) = expectedLength p ℓ :=
    Finset.sum_congr rfl fun i _ => by simp only [hlen i]
  refine ⟨c, hinj, hpf, by rw [hcongk, hk], ?_⟩
  rw [hcongE]
  exact dyadic_code_achieves_entropy p ℓ hdy

/-! ## Thermodynamic corollaries -/

/-- **The Landauer floor is attained.**  For a dyadic theorem ensemble there is an actual
prefix-free description scheme whose expected erasure cost equals the entropy floor
`H(p) · k_B T ln 2`. -/
theorem landauer_floor_attainable {ι : Type*} [Fintype ι] [DecidableEq ι]
    (p : ι → ℝ) (hsum : ∑ i, p i = 1) (ℓ : ι → ℕ)
    (hdy : ∀ i, p i = ((2 : ℝ)⁻¹) ^ ℓ i) (kB T : ℝ) :
    ∃ c : ι → List Bool, Function.Injective c ∧ PrefixFree (Finset.univ.image c) ∧
      ∑ i, p i * landauerCost ((c i).length : ℝ) kB T = landauerCost (entropy p) kB T := by
  obtain ⟨c, hinj, hpf, _, hE⟩ := exists_complete_code_of_dyadic p hsum ℓ hdy
  refine ⟨c, hinj, hpf, ?_⟩
  have hlin : ∑ i, p i * landauerCost ((c i).length : ℝ) kB T
      = landauerCost (expectedLength p (fun i => (c i).length)) kB T := by
    unfold landauerCost expectedLength
    rw [Finset.sum_mul]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hlin, hE]

/-- **The entropy floor is approached within one Landauer quantum.**  For an arbitrary
ensemble the optimal prefix-free description scheme dissipates at least `H(p) k_B T ln 2` and
at most one quantum `k_B T ln 2` more. -/
theorem landauer_floor_within_one_bit {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1) {kB T : ℝ} (hkB : 0 < kB)
    (hT : 0 < T) :
    ∃ c : ι → List Bool, Function.Injective c ∧ PrefixFree (Finset.univ.image c) ∧
      landauerCost (entropy p) kB T ≤ ∑ i, p i * landauerCost ((c i).length : ℝ) kB T ∧
      ∑ i, p i * landauerCost ((c i).length : ℝ) kB T
        < landauerCost (entropy p) kB T + kB * T * Real.log 2 := by
  obtain ⟨c, hinj, hpf, hlow, hhigh⟩ := shannon_source_coding p hp hsum
  have hfac : (0 : ℝ) < kB * T * Real.log 2 := by
    have : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    positivity
  have hlin : ∑ i, p i * landauerCost ((c i).length : ℝ) kB T
      = landauerCost (expectedLength p (fun i => (c i).length)) kB T := by
    unfold landauerCost expectedLength
    rw [Finset.sum_mul]
    exact Finset.sum_congr rfl fun i _ => by ring
  refine ⟨c, hinj, hpf, ?_, ?_⟩
  · rw [hlin]
    unfold landauerCost
    exact mul_le_mul_of_nonneg_right hlow hfac.le
  · rw [hlin]
    unfold landauerCost
    have := mul_lt_mul_of_pos_right hhigh hfac
    linarith [this]

/-! ## Completeness is tiling: a complete prefix code wastes no description space -/

/-- The real Kraft sum of a finite word set, rescaled to depth `L`. -/
lemma cast_sum_two_pow_sub (S : Finset (List Bool)) {L : ℕ} (hL : ∀ w ∈ S, w.length ≤ L) :
    ((∑ w ∈ S, 2 ^ (L - w.length) : ℕ) : ℝ)
      = 2 ^ L * ∑ w ∈ S, ((2 : ℝ)⁻¹) ^ w.length := by
  push_cast
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun w hw => ?_
  have h : w.length + (L - w.length) = L := by have := hL w hw; omega
  have h2 : (2 : ℝ) ^ L = 2 ^ w.length * 2 ^ (L - w.length) := by rw [← pow_add, h]
  rw [h2, inv_pow]
  field_simp

/-- **Completeness is tiling.**  A prefix-free set of descriptions whose Kraft sum is exactly
`1` partitions the space of binary words of any depth `L` bounding its lengths: the cylinders
of the codewords cover every word of length `L` exactly once. -/
theorem complete_code_tiles {S : Finset (List Bool)} (hpf : PrefixFree S) {L : ℕ}
    (hL : ∀ w ∈ S, w.length ≤ L)
    (hcomp : ∑ w ∈ S, ((2 : ℝ)⁻¹) ^ w.length = 1) :
    S.biUnion (cylinder L) = boolLists L := by
  classical
  have hnat : ∑ w ∈ S, 2 ^ (L - w.length) = 2 ^ L := by
    have := cast_sum_two_pow_sub S hL
    rw [hcomp, mul_one] at this
    exact_mod_cast this
  refine Finset.eq_of_subset_of_card_le
    (Finset.biUnion_subset.2 fun w _ => cylinder_subset L w) ?_
  rw [card_boolLists,
    Finset.card_biUnion (fun u hu v hv huv => cylinder_disjoint hpf L hu hv huv), ← hnat]
  exact le_of_eq (Finset.sum_congr rfl fun w hw => (card_cylinder (hL w hw)).symm)

/-- **Unique decodability of a complete code.**  Every binary word of the ambient depth has
exactly one codeword as a prefix. -/
theorem complete_code_unique_prefix {S : Finset (List Bool)} (hpf : PrefixFree S) {L : ℕ}
    (hL : ∀ w ∈ S, w.length ≤ L) (hcomp : ∑ w ∈ S, ((2 : ℝ)⁻¹) ^ w.length = 1)
    {u : List Bool} (hu : u.length = L) : ∃! w, w ∈ S ∧ w <+: u := by
  classical
  have hmem : u ∈ S.biUnion (cylinder L) := by
    rw [complete_code_tiles hpf hL hcomp, mem_boolLists]
    exact hu
  obtain ⟨w, hwS, hwc⟩ := Finset.mem_biUnion.1 hmem
  simp only [cylinder, Finset.mem_filter] at hwc
  refine ⟨w, ⟨hwS, hwc.2⟩, ?_⟩
  rintro v ⟨hvS, hvu⟩
  rcases le_total v.length w.length with hle | hle
  · exact hpf v hvS w hwS (List.prefix_of_prefix_length_le hvu hwc.2 hle)
  · exact (hpf w hwS v hvS (List.prefix_of_prefix_length_le hwc.2 hvu hle)).symm

/-- **The optimal code of a dyadic ensemble tiles description space.**  Combining the
converse of Kraft with the equality case of the source-coding bound: for a dyadic theorem
ensemble there is a prefix-free description scheme that attains the Shannon entropy *and*
wastes no description space at all — every binary string of the ambient depth is decoded by
exactly one theorem description. -/
theorem dyadic_optimal_code_tiles {ι : Type*} [Fintype ι] [DecidableEq ι]
    (p : ι → ℝ) (hsum : ∑ i, p i = 1) (ℓ : ι → ℕ)
    (hdy : ∀ i, p i = ((2 : ℝ)⁻¹) ^ ℓ i) :
    ∃ c : ι → List Bool, Function.Injective c ∧ PrefixFree (Finset.univ.image c) ∧
      expectedLength p (fun i => (c i).length) = entropy p ∧
      ∀ L : ℕ, (∀ i, (c i).length ≤ L) →
        (Finset.univ.image c).biUnion (cylinder L) = boolLists L := by
  classical
  obtain ⟨c, hinj, hpf, hkone, hE⟩ := exists_complete_code_of_dyadic p hsum ℓ hdy
  refine ⟨c, hinj, hpf, hE, ?_⟩
  intro L hLc
  have hcomp : ∑ w ∈ Finset.univ.image c, ((2 : ℝ)⁻¹) ^ w.length = 1 := by
    rw [Finset.sum_image (fun a _ b _ hab => hinj hab)]
    exact hkone
  refine complete_code_tiles hpf ?_ hcomp
  intro w hw
  obtain ⟨i, _, rfl⟩ := Finset.mem_image.1 hw
  exact hLc i

/-! ## A worked example: the packing of the profile `(1, 2, 2)` -/

/-- The packing construction applied to the sorted profile `ℓ = (1, 2, 2)` returns exactly
the classical complete code `{0, 10, 11}` whose prefix-freeness and Kraft completeness were
computed in `PrefixFreeThermoCoding`. -/
example : (word 2 (fun i => if i = 0 then 1 else 2) 0,
    word 2 (fun i => if i = 0 then 1 else 2) 1,
    word 2 (fun i => if i = 0 then 1 else 2) 2)
    = ([false], [true, false], [true, true]) := by
  decide

end KraftConverse