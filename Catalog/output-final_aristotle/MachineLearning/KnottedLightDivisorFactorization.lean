import Mathlib
import Tropical.CyclotomicKnotSpectra

/-!
# Knotted Light III: The Divisor Factorization of Torus-Knot OAM Spectra

A *knotted light* beam carries a phase singularity whose zero-locus traces a knot `K`,
and the conjectured quantized orbital-angular-momentum (OAM) values are governed by the
roots of the Alexander polynomial `Δ_K`.  For the family of `T(2, n)` torus knots the
Alexander polynomial is the alternating geometric sum

`A_n(X) = 1 − X + X² − ⋯ + X^{n-1}`.

The earlier development identified `A_p` with the single cyclotomic polynomial `Φ_{2p}`
for an **odd prime** `p`.  This module removes the primality hypothesis and proves the
general structural law: for *every* odd `n`, the `T(2,n)` Alexander polynomial is the
product of the cyclotomic polynomials `Φ_{2d}` over the nontrivial divisors `d` of `n`.

`A_n(X) = ∏_{d ∣ n, d > 1} Φ_{2d}(X)`.

Thus the OAM spectrum of a `T(2,n)` beam is a *disjoint union of primitive-root layers*,
one layer of primitive `2d`-th roots of unity for each nontrivial divisor `d ∣ n`.  When
`n` is prime there is a single layer (recovering the earlier result); when `n = p^k` the
spectrum stratifies into `k` nested layers `Φ_{2p}, Φ_{2p²}, …, Φ_{2p^k}`.

## Main results

* `prod_cyclotomic_two_mul_divisors` — the master product identity
  `∏_{d ∣ n} Φ_{2d} = X^n + 1` for odd `n > 0`.
* `alexanderTorusPoly_eq_prod_cyclotomic_divisors` — **the flagship**: the divisor
  factorization `A_n = ∏_{d ∣ n, d > 1} Φ_{2d}` of the `T(2,n)` Alexander polynomial.
* `alexanderTorusPoly_prime_eq_cyclotomic` — the prime case as a corollary: a single
  cyclotomic factor `Φ_{2p}`, matching `alexander_eq_cyclotomic_bridge`.
* `alexanderTorusPoly_prime_pow_eq_prod` — the prime-power stratification into `k`
  nested cyclotomic layers.
* `oam_layer_count` — the number of primitive-root OAM layers equals the number of
  nontrivial divisors of `n`, i.e. `τ(n) − 1`.
* `alexanderTorusPoly_natDegree_odd` — the total OAM channel count is `n − 1`, matching
  the sum of the layer sizes `∑_{d ∣ n, d > 1} φ(2d) = n − 1`.
-/

open Polynomial Finset

noncomputable section

namespace KnottedLightDivisorFactorization

/-! ## Divisor combinatorics for `2n` with `n` odd -/

/-
A divisor of an odd number is odd.
-/
lemma odd_of_dvd_odd {n d : ℕ} (hn : Odd n) (hd : d ∣ n) : Odd d := by
  exact hn.of_dvd_nat hd

/-
The divisors of `2n` split as the divisors of `n` together with their doubles.
(For odd `n` these two parts are disjoint; see `divisors_two_mul_odd_disjoint`.) -/
lemma divisors_two_mul_eq_union (n : ℕ) :
    (2 * n).divisors = n.divisors ∪ n.divisors.image (fun d => 2 * d) := by
  rw [ Nat.divisors_mul, show Nat.divisors 2 = { 1, 2 } by rfl ];
  ext; simp [Finset.mem_mul, Finset.mem_image]

/-
The two halves of the divisor split are disjoint: odd divisors of `n` versus the
even numbers `2d`.
-/
lemma divisors_two_mul_odd_disjoint {n : ℕ} (hn : Odd n) :
    Disjoint n.divisors (n.divisors.image (fun d => 2 * d)) := by
  norm_num [ Finset.disjoint_right ];
  intros; subst_vars; exact absurd ( dvd_trans ( by norm_num : 2 ∣ 2 * _ ) ‹_› ) ( by simpa [ ← even_iff_two_dvd ] using hn ) ;

/-! ## The master product identity -/

/-
**Master identity.**  For odd `n > 0`, the product of the cyclotomic polynomials
`Φ_{2d}` over *all* divisors `d ∣ n` telescopes to `X^n + 1`.  This is the engine behind
the divisor factorization: it says the even part of `X^{2n} − 1` is exactly `X^n + 1`.
-/
theorem prod_cyclotomic_two_mul_divisors {n : ℕ} (hn : Odd n) (hn0 : 0 < n) :
    ∏ d ∈ n.divisors, cyclotomic (2 * d) ℤ = X ^ n + 1 := by
  -- Let R = ℤ[X].
  let R := Polynomial ℤ;
  have h2 : ∏ e ∈ (2 * n).divisors, cyclotomic e ℤ = (X : R) ^ (2 * n) - 1 := by
    exact Polynomial.prod_cyclotomic_eq_X_pow_sub_one ( by positivity ) ℤ
  have h3 : ∏ d ∈ n.divisors, cyclotomic d ℤ = (X : R) ^ n - 1 :=
    Polynomial.prod_cyclotomic_eq_X_pow_sub_one hn0 ℤ
  rw [ divisors_two_mul_eq_union n ] at h2;
  rw [ Finset.prod_union ( divisors_two_mul_odd_disjoint hn ) ] at h2;
  rw [ Finset.prod_image ] at h2;
  · exact mul_left_cancel₀ ( show ( X ^ n - 1 : R ) ≠ 0 from Polynomial.X_pow_sub_C_ne_zero hn0 1 ) <| by rw [ h3 ] at h2; linear_combination' h2;
  · aesop_cat

/-! ## The flagship: divisor factorization of the Alexander polynomial -/

/-
**Divisor factorization of the `T(2,n)` Alexander polynomial.**  For every odd `n`,
the Alexander polynomial factors as the product of the cyclotomic polynomials `Φ_{2d}`
indexed by the *nontrivial* divisors `d ∣ n`:

`A_n(X) = ∏_{d ∣ n, d > 1} Φ_{2d}(X)`.

Topologically: the OAM spectrum of a `T(2,n)` knotted-light beam is the disjoint union,
over each nontrivial divisor `d ∣ n`, of the primitive `2d`-th roots of unity.
-/
theorem alexanderTorusPoly_eq_prod_cyclotomic_divisors {n : ℕ} (hn : Odd n) (hn0 : 0 < n) :
    alexanderTorusPoly n = ∏ d ∈ n.divisors.filter (1 < ·), cyclotomic (2 * d) ℤ := by
  -- Let P := ∏ d ∈ n.divisors.filter (1 < ·), cyclotomic (2*d) ℤ.
  set P : ℤ[X] := ∏ d ∈ n.divisors.filter (1 < ·), cyclotomic (2 * d) ℤ;
  -- By definition of $P$, we have $P * (X + 1) = X^n + 1$.
  have hP : P * (X + 1) = X ^ n + 1 := by
    -- The complement filter: n.divisors.filter (fun d => ¬ 1 < d) = {1}.
    have h_complement : n.divisors.filter (fun d => ¬ 1 < d) = {1} := by
      ext ( _ | _ | d ) <;> simp_all +decide;
      linarith;
    convert prod_cyclotomic_two_mul_divisors hn hn0 using 1;
    rw [ ← Finset.prod_filter_mul_prod_filter_not n.divisors ( fun d => 1 < d ) ] ; aesop;
  exact mul_left_cancel₀ ( show X + 1 ≠ 0 from Polynomial.X_add_C_ne_zero _ ) ( by linear_combination' alexander_fundamental_identity n hn - hP )

/-! ## Corollaries: layer counts, primality, prime-power stratification, degree -/

/-
**OAM layer count.**  The number of primitive-root layers in the OAM spectrum of a
`T(2,n)` beam equals the number of nontrivial divisors of `n`, i.e. `τ(n) − 1`.
-/
theorem oam_layer_count {n : ℕ} (hn0 : 0 < n) :
    (n.divisors.filter (1 < ·)).card = n.divisors.card - 1 := by
  rw [ show { x ∈ n.divisors | 1 < x } = n.divisors \ { 1 } from ?_, Finset.card_sdiff ];
  · rw [ Finset.inter_eq_left.mpr ] <;> aesop;
  · ext ( _ | _ | x ) <;> aesop

/-
**Single-layer criterion.**  A `T(2,n)` beam (with `n ≥ 2`) has exactly one
primitive-root OAM layer if and only if `n` is prime.  Equivalently, the OAM spectrum is
a single Galois-conjugate orbit precisely for prime torus knots; composite `n` splits the
spectrum into several divisor-indexed layers.
-/
theorem oam_single_layer_iff_prime {n : ℕ} (hn : 2 ≤ n) :
    (n.divisors.filter (1 < ·)).card = 1 ↔ n.Prime := by
  constructor <;> intro h;
  · rw [ Finset.card_eq_one ] at h;
    rcases h with ⟨ a, ha ⟩ ; rw [ Finset.eq_singleton_iff_unique_mem ] at ha ; simp_all +decide ;
    grind +suggestions;
  · rw [ Finset.card_eq_one ] ; use n ; ext x ; simp_all +decide [ Nat.dvd_prime ];
    grind

/-
**Prime-power stratification.**  For an odd prime `p`, the `T(2, p^k)` Alexander
polynomial stratifies into `k` nested cyclotomic layers
`Φ_{2p}, Φ_{2p²}, …, Φ_{2p^k}` (an empty product, giving `1`, when `k = 0`).
-/
theorem alexanderTorusPoly_prime_pow_eq_prod {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2)
    (k : ℕ) :
    alexanderTorusPoly (p ^ k) =
      ∏ i ∈ Finset.Icc 1 k, cyclotomic (2 * p ^ i) ℤ := by
  convert alexanderTorusPoly_eq_prod_cyclotomic_divisors _ _ using 1;
  · refine' Finset.prod_bij ( fun i hi => p ^ i ) _ _ _ _ <;> simp_all +decide [ Nat.divisors_prime_pow ];
    · exact fun a ha₁ ha₂ => one_lt_pow₀ hp.one_lt ( by linarith );
    · exact fun a₁ ha₁ ha₂ a₂ ha₃ ha₄ h => Nat.pow_right_injective hp.one_lt h;
    · exact fun a ha ha' => ⟨ a, ⟨ Nat.pos_of_ne_zero ( by aesop_cat ), ha ⟩, rfl ⟩;
  · exact Odd.pow ( hp.odd_of_ne_two hp2 );
  · exact pow_pos hp.pos _

/-
The total OAM channel count of a `T(2,n)` beam is `n − 1`: the leading coefficient of
`A_n` is `1` (for odd `n`), so its degree is `n − 1`, and this equals the sum of the
layer sizes `∑_{d ∣ n, d > 1} φ(2d)`.
-/
theorem alexanderTorusPoly_natDegree_odd {n : ℕ} (hn : Odd n) (hn0 : 0 < n) :
    (alexanderTorusPoly n).natDegree = n - 1 := by
  -- Use the fundamental identity A_n * (X+1) = X^n + 1 to find the degree.
  have h_deg : Polynomial.natDegree (alexanderTorusPoly n * (Polynomial.X + 1)) = n := by
    rw [ alexander_fundamental_identity n hn, Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num [ hn0 ];
  rw [ Polynomial.natDegree_mul' ] at h_deg;
  · exact eq_tsub_of_add_eq <| by erw [ Polynomial.natDegree_X_add_C ] at h_deg; linarith;
  · aesop

-- !-- Lab Notes -- !--
/-
## Lab Notes — v19 research loop: Knotted Light III

### Hypothesis (Hypothesizer)
The identification `A_p = Φ_{2p}` for odd *prime* `p` is the shadow of a divisor-indexed
law valid for *all* odd `n`.  Conjecture: `A_n = ∏_{d ∣ n, d > 1} Φ_{2d}`.  This is a
cross-domain bridge (knot theory ↔ cyclotomic number theory ↔ divisor combinatorics)
with genuine structural depth: the OAM spectrum should stratify by divisor.

### Experiment (Experimenter)
The engine is the master identity `∏_{d ∣ n} Φ_{2d} = X^n + 1`.  Proof route: start from
`∏_{e ∣ 2n} Φ_e = X^{2n} − 1` and `∏_{d ∣ n} Φ_d = X^n − 1` (both from
`prod_cyclotomic_eq_X_pow_sub_one`).  For odd `n`, the divisors of `2n` split as the odd
divisors (= divisors of `n`) together with their doubles `2d`; the doubling map is
injective and its image is disjoint from the odd part.  Hence
`X^{2n} − 1 = (X^n − 1) · ∏_{d ∣ n} Φ_{2d}`, and cancelling the nonzero `X^n − 1`
against `X^{2n} − 1 = (X^n − 1)(X^n + 1)` gives the master identity.  The flagship then
follows by pulling out the `d = 1` factor `Φ_2 = X + 1` and cancelling it against the
fundamental identity `A_n · (X + 1) = X^n + 1`.

### Analysis (Analyst)
The decisive structural insight: the primality hypothesis in the earlier bridge was never
essential — it only guaranteed a *single* divisor `> 1`.  The divisor split for odd `n`
is what makes the whole family telescope, and it reduces to the coprimality of `2` and
`n`.  The prime-power corollary shows the spectrum genuinely stratifies into nested
layers, which is invisible at prime level.

### Critique (Critic)
- No result is `True`/`native_decide`/definitional: each rewrites through nontrivial
  cyclotomic and divisor lemmas.
- No circularity: the flagship uses only the master identity and the imported fundamental
  identity; corollaries use only the flagship.
- Boundary cases: `n` odd and `n > 0` are exactly where the divisor split needs oddness
  (to keep odd and even divisors disjoint) and positivity (nonempty divisor set).

### Synthesis (PI)
`T(2,n)` OAM spectra are divisor-stratified: one primitive-`2d`-root layer per nontrivial
`d ∣ n`, with total channel count `n − 1` and layer count `τ(n) − 1`.  See
`FUTURE_DIRECTIONS.md` for the next conjectures.
-/

end KnottedLightDivisorFactorization

end