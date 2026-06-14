/-
  # The Hodge–Deligne E-polynomial as a Motivic Measure

  This file develops the Hodge–Deligne E-polynomial

      E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ

  on an abstract combinatorial `HodgeDiamond` (complex dimension `dim` together
  with integer Hodge numbers `h p q`), and promotes it from a *single-variety*
  invariant to a *ring / measure level* invariant.

  We introduce the three universal operations on Hodge diamonds — direct sum
  `directSum`, tensor product `tensorProd` (the genuine Künneth convolution of
  Hodge numbers) and the Tate / Lefschetz twist `tateTwist` — and prove how `E`
  transforms under each:

  * `epoly_directSum`  — additivity            `E(X ⊕ Y) = E(X) + E(Y)`;
  * `epoly_kunneth`    — Künneth multiplicativity `E(X ⊗ Y) = E(X) · E(Y)`;
  * `eulerChar_kunneth`— numerical product law `χ(X ⊗ Y) = χ(X) · χ(Y)`;
  * `epoly_tateTwist`  — `E(X(1)) = uv · E(X)` (the Tate twist is the Lefschetz
                          class `𝕃 = uv`);
  * `epoly_serre_functional_equation` — Serre duality gives the Poincaré
                          functional equation `E(X) = (uv)ⁿ E(X; 1/u, 1/v)`;
  * `poincare_serre_palindrome` — its one-variable shadow `P(X; t) = t^{2n} P(X; 1/t)`.

  Together these say: `X ↦ E(X; u, v)` is a homomorphism of (semi)rings from the
  Grothendieck ring of supported Hodge diamonds (under `⊕`, `⊗`) into `K[u, v]`,
  intertwining the Tate twist with multiplication by `uv`.  In one phrase: **the
  E-polynomial is a motivic measure**.

  The proof rests on two reusable lemmas extracted in the file, `cauchy_prod_1D`
  and `cauchy_prod_2D` (truncated Cauchy products under a support hypothesis),
  which are exactly the local-to-global engine: the *global* invariant of a
  product factors through the *local* (factor) data, and the only assumption
  needed is `Supported`.

  Everything is over an arbitrary commutative ring `R` (a field `K` for the
  functional equation, where inverses appear).
-/
import Mathlib

open Finset

namespace HodgeEPolynomial

-- !-- Lab Notebook -- !--
-- Hypothesis: the signed two-variable E-polynomial of an abstract Hodge diamond
--   is a *motivic measure* — additive on direct sums, multiplicative on the
--   Künneth tensor product, and intertwining the Tate twist with multiplication
--   by the Lefschetz class 𝕃 = uv — and Serre duality forces a palindromic
--   functional equation.
-- Result: all headline facts proved with no `sorry` (cauchy_prod_1D,
--   cauchy_prod_2D, epoly_directSum, epoly_kunneth, eulerChar_kunneth,
--   epoly_tateTwist, epoly_serre_functional_equation, poincare_serre_palindrome).
-- Insight: the sign factorises, (-1)^{p+q} = (-1)^i(-1)^{p-i}(-1)^k(-1)^{q-k}
--   on the antidiagonal i+j=p, k+l=q, so the *entire* term function
--   T(i,k) = (-1)^{i+k} h(i,k) uⁱ vᵏ is multiplicative under convolution. Thus a
--   single truncated 2-D Cauchy product (`cauchy_prod_2D`) is the one engine that
--   powers Künneth; additivity is plain linearity and the Tate twist is a clean
--   reindex of the diamond by (p,q) ↦ (p+1,q+1).
-- Failure analysis: the support hypothesis `Supported` is essential — without it
--   `tensorProd`'s convolution range and the factor ranges do not line up and the
--   truncation in `cauchy_prod_2D` drops genuinely nonzero terms. The functional
--   equation must live over a *field* (inverses u⁻¹, v⁻¹) and uses the parity
--   identity (-1)^{2n-p-q} = (-1)^{p+q}.

/-! ## The abstract Hodge diamond -/

/-- An abstract **Hodge diamond**: a complex dimension `dim` together with integer
Hodge numbers `h p q` (the `(p,q)` Hodge number).  Negative or out-of-range
entries are simply `0` for a *supported* diamond. -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  dim : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

/-- A diamond is **`Supported`** when its Hodge numbers are concentrated in
bidegrees `0 ≤ p, q ≤ dim`, the algebraic shadow of a pure Hodge structure on a
smooth projective variety of complex dimension `dim`. -/
def HodgeDiamond.Supported (X : HodgeDiamond) : Prop :=
  ∀ p q, (X.dim < p ∨ X.dim < q) → X.h p q = 0

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated at ring elements `u v : R`. -/
def EPoly {R : Type*} [CommRing R] (X : HodgeDiamond) (u v : R) : R :=
  ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1),
    (-1 : R) ^ (p + q) * (X.h p q : R) * u ^ p * v ^ q

/-- The **topological Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1),
    (-1 : ℤ) ^ (p + q) * X.h p q

/-- The one-variable **Poincaré polynomial** `P(X; t) = E(X; t, t)`. -/
def poincarePoly {R : Type*} [CommRing R] (X : HodgeDiamond) (t : R) : R := EPoly X t t

/-! ## The three universal operations -/

/-- **Direct sum** of Hodge diamonds: `h^{p,q}(X ⊕ Y) = h^{p,q}(X) + h^{p,q}(Y)`. -/
def directSum (X Y : HodgeDiamond) : HodgeDiamond where
  dim := max X.dim Y.dim
  h := fun p q => X.h p q + Y.h p q

/-- **Tensor product** of Hodge diamonds, with the genuine Künneth convolution of
Hodge numbers `h^{p,q}(X ⊗ Y) = Σ_{i+j=p, k+l=q} h^{i,k}(X) h^{j,l}(Y)`. -/
def tensorProd (X Y : HodgeDiamond) : HodgeDiamond where
  dim := X.dim + Y.dim
  h := fun p q => ∑ i ∈ Finset.range (p + 1), ∑ k ∈ Finset.range (q + 1),
        X.h i k * Y.h (p - i) (q - k)

/-- The **Tate / Lefschetz twist** `X(1)`: shift the diamond by `(p,q) ↦ (p+1,q+1)`,
so `h^{p,q}(X(1)) = h^{p-1,q-1}(X)` (and `0` on the `p = 0` or `q = 0` edge). -/
def tateTwist (X : HodgeDiamond) : HodgeDiamond where
  dim := X.dim + 1
  h := fun p q => match p, q with
        | p + 1, q + 1 => X.h p q
        | _, _ => 0

/-! ## The Cauchy-product engine -/

/-
!-- comment -- !--
Extend both factor sums to `range (N+M+1)` (the new terms vanish by support),
expand the product with `Finset.sum_mul_sum`, and regroup the double sum by the
value `p = i + j` of the antidiagonal via `Finset.sum_range_succ`-style nested
reindexing; terms with `p > N+M` are zero.
!-- comment -- !--

**Truncated 1-D Cauchy product.**  For `f` supported on `[0,N]` and `g` on
`[0,M]`, the product of the truncated sums is the convolution truncated at
`N+M`.
-/
theorem cauchy_prod_1D {R : Type*} [CommRing R] (f g : ℕ → R) (N M : ℕ)
    (hf : ∀ i, N < i → f i = 0) (hg : ∀ j, M < j → g j = 0) :
    (∑ i ∈ range (N + 1), f i) * (∑ j ∈ range (M + 1), g j)
      = ∑ p ∈ range (N + M + 1), ∑ i ∈ range (p + 1), f i * g (p - i) := by
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ p ∈ Finset.range (N + M + 1), ∑ i ∈ Finset.range (p + 1), f i * g (p - i) = ∑ i ∈ Finset.range (N + 1), ∑ j ∈ Finset.range (M + 1), f i * g j := by
    have h_fubini : ∀ p ∈ Finset.range (N + M + 1), ∑ i ∈ Finset.range (p + 1), f i * g (p - i) = ∑ i ∈ Finset.filter (fun i => i ≤ p ∧ p - i ≤ M) (Finset.range (N + 1)), f i * g (p - i) := by
      intro p hp; rw [ ← Finset.sum_subset ] ; simp +contextual [ Finset.subset_iff ] ;
      grind;
    rw [ Finset.sum_congr rfl h_fubini ];
    rw [ Finset.sum_sigma', Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun x hx => ⟨ x.snd, x.fst - x.snd ⟩ ) _ _ _ _ <;> simp +decide;
    · exact fun a ha₁ ha₂ ha₃ ha₄ => ⟨ ha₂, ha₄ ⟩;
    · grind;
    · exact fun b hb₁ hb₂ => ⟨ b.fst + b.snd, b.fst, ⟨ by linarith, by linarith, by linarith, by linarith ⟩, by simp +decide ⟩;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ]

/-
!-- comment -- !--
Two applications of the 1-D form: hold the second pair of indices fixed and run
`cauchy_prod_1D` on the first coordinate, then on the second; the support
hypotheses pass through coordinatewise.
!-- comment -- !--

**Truncated 2-D Cauchy product.**  For `f` supported on `[0,N]²` and `g` on
`[0,M]²`, the product of the truncated double sums is the 2-D convolution
truncated at `N+M` in each coordinate.
-/
theorem cauchy_prod_2D {R : Type*} [CommRing R] (f g : ℕ → ℕ → R) (N M : ℕ)
    (hf : ∀ i k, (N < i ∨ N < k) → f i k = 0)
    (hg : ∀ j l, (M < j ∨ M < l) → g j l = 0) :
    (∑ i ∈ range (N + 1), ∑ k ∈ range (N + 1), f i k)
      * (∑ j ∈ range (M + 1), ∑ l ∈ range (M + 1), g j l)
      = ∑ p ∈ range (N + M + 1), ∑ q ∈ range (N + M + 1),
          ∑ i ∈ range (p + 1), ∑ k ∈ range (q + 1), f i k * g (p - i) (q - k) := by
  -- Apply the Cauchy product formula to the two sums.
  have h_cauchy : (∑ i ∈ Finset.range (N + 1), ∑ k ∈ Finset.range (N + 1), f i k) * (∑ j ∈ Finset.range (M + 1), ∑ l ∈ Finset.range (M + 1), g j l) = ∑ p ∈ Finset.range (N + M + 1), ∑ i ∈ Finset.range (p + 1), (∑ k ∈ Finset.range (N + 1), f i k) * (∑ l ∈ Finset.range (M + 1), g (p - i) l) := by
    convert cauchy_prod_1D ( fun i => ∑ k ∈ Finset.range ( N + 1 ), f i k ) ( fun j => ∑ l ∈ Finset.range ( M + 1 ), g j l ) N M _ _ using 1;
    · exact fun i hi => Finset.sum_eq_zero fun k hk => hf i k <| Or.inl hi;
    · exact fun j hj => Finset.sum_eq_zero fun l hl => hg j l <| Or.inl hj;
  -- Apply the Cauchy product formula to the inner sums.
  have h_inner : ∀ p ∈ Finset.range (N + M + 1), ∀ i ∈ Finset.range (p + 1), (∑ k ∈ Finset.range (N + 1), f i k) * (∑ l ∈ Finset.range (M + 1), g (p - i) l) = ∑ q ∈ Finset.range (N + M + 1), ∑ k ∈ Finset.range (q + 1), f i k * g (p - i) (q - k) := by
    intro p hp i hi;
    convert cauchy_prod_1D ( fun k => f i k ) ( fun l => g ( p - i ) l ) N M _ _ using 1;
    · exact fun k hk => hf i k ( Or.inr hk );
    · exact fun j hj => hg _ _ ( Or.inr hj );
  rw [ h_cauchy, Finset.sum_congr rfl fun p hp => Finset.sum_congr rfl fun i hi => h_inner p hp i hi ];
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm

/-! ## Additivity: `E(X ⊕ Y) = E(X) + E(Y)` -/

/-
!-- comment -- !--
A `Supported` diamond's E-polynomial is unchanged when the summation range is
enlarged, since the extra Hodge numbers vanish; this is the technical lemma
that lets us compare `E` over different `dim`s (e.g. `max X.dim Y.dim`).
!-- comment -- !--

Enlarging the summation range past the support does not change `E`.
-/
theorem epoly_range_extend {R : Type*} [CommRing R] (X : HodgeDiamond)
    (hX : X.Supported) (N : ℕ) (hN : X.dim ≤ N) (u v : R) :
    ∑ p ∈ range (N + 1), ∑ q ∈ range (N + 1),
        (-1 : R) ^ (p + q) * (X.h p q : R) * u ^ p * v ^ q
      = EPoly X u v := by
  rw [ ← Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ hN ) ) ];
  · refine' Finset.sum_congr rfl fun p hp => _;
    rw [ ← Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ hN ) ) ];
    simp +zetaDelta at *;
    exact fun q hq hq' => by rw [ hX p q ( Or.inr hq' ) ] ; simp +decide ;
  · simp +zetaDelta at *;
    exact fun x hx hx' => Finset.sum_eq_zero fun q hq => by rw [ hX x q ( Or.inl hx' ) ] ; simp +decide ;

/-
!-- comment -- !--
Extend both `E(X)` and `E(Y)` to the common range `max X.dim Y.dim` via
`epoly_range_extend`, then additivity is linearity of the (double) finite sum.
!-- comment -- !--

**Additivity.**  `E(X ⊕ Y) = E(X) + E(Y)`.
-/
theorem epoly_directSum {R : Type*} [CommRing R] (X Y : HodgeDiamond)
    (hX : X.Supported) (hY : Y.Supported) (u v : R) :
    EPoly (directSum X Y) u v = EPoly X u v + EPoly Y u v := by
  unfold EPoly directSum;
  simp +decide [ mul_add, add_mul, Finset.sum_add_distrib ];
  congr! 1;
  · convert epoly_range_extend X hX ( Max.max X.dim Y.dim ) ( le_max_left _ _ ) u v using 1;
  · convert epoly_range_extend Y hY ( Max.max X.dim Y.dim ) ( le_max_right X.dim Y.dim ) u v using 1

/-! ## Künneth multiplicativity: `E(X ⊗ Y) = E(X) · E(Y)` -/

/-
!-- comment -- !--
Apply `cauchy_prod_2D` to the term functions f(i,k)=(-1)^{i+k} h_X(i,k) uⁱ vᵏ
and g(j,l)=(-1)^{j+l} h_Y(j,l) uʲ vˡ. The sign factorises on the antidiagonal,
(-1)^{p+q} = (-1)^{i+k}(-1)^{(p-i)+(q-k)} when i ≤ p, k ≤ q, and uᵖ = uⁱ u^{p-i};
support of f, g comes from `Supported X`, `Supported Y`.
!-- comment -- !--

**Künneth multiplicativity.**  `E(X ⊗ Y) = E(X) · E(Y)` for supported
diamonds.
-/
theorem epoly_kunneth {R : Type*} [CommRing R] (X Y : HodgeDiamond)
    (hX : X.Supported) (hY : Y.Supported) (u v : R) :
    EPoly (tensorProd X Y) u v = EPoly X u v * EPoly Y u v := by
  unfold EPoly;
  rw [ cauchy_prod_2D ];
  · refine' Finset.sum_congr rfl fun p hp => Finset.sum_congr rfl fun q hq => _;
    simp +decide [ tensorProd, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
    refine' Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => _;
    rw [ show p = i + ( p - i ) by rw [ Nat.add_sub_cancel' ( Finset.mem_range_succ_iff.mp hi ) ], show q = j + ( q - j ) by rw [ Nat.add_sub_cancel' ( Finset.mem_range_succ_iff.mp hj ) ] ] ; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm ];
  · intro i k h; specialize hX i k h; aesop;
  · intro j l h; specialize hY j l; aesop;

/-
!-- comment -- !--
Specialise `epoly_kunneth` to `R = ℤ`, `u = v = 1`, using
`epoly_one_one_eq_eulerChar` to identify `E(·;1,1)` with `χ`.
!-- comment -- !--

`E(X; 1, 1) = χ(X)`.
-/
theorem epoly_one_one_eq_eulerChar (X : HodgeDiamond) :
    EPoly X (1 : ℤ) (1 : ℤ) = eulerChar X := by
  unfold EPoly eulerChar; aesop;

/-
**Numerical Künneth.**  `χ(X ⊗ Y) = χ(X) · χ(Y)`.
-/
theorem eulerChar_kunneth (X Y : HodgeDiamond)
    (hX : X.Supported) (hY : Y.Supported) :
    eulerChar (tensorProd X Y) = eulerChar X * eulerChar Y := by
  rw [ ← epoly_one_one_eq_eulerChar, ← epoly_one_one_eq_eulerChar X, ← epoly_one_one_eq_eulerChar Y, epoly_kunneth X Y hX hY ]

/-! ## The Tate twist: `E(X(1)) = uv · E(X)` -/

/-
!-- comment -- !--
`tateTwist X` has dimension `X.dim + 1`; its E-sum over `range (dim+2)` has all
`p = 0` and `q = 0` terms zero, and the remaining `(p+1,q+1)` terms reindex
(`Finset.sum_range_succ'`) to `uv` times the `(p,q)` term of `E(X)`.
!-- comment -- !--

**Tate twist law.**  `E(X(1); u, v) = uv · E(X; u, v)`; the Tate twist acts as
multiplication by the Lefschetz class `𝕃 = uv`.
-/
theorem epoly_tateTwist {R : Type*} [CommRing R] (X : HodgeDiamond) (u v : R) :
    EPoly (tateTwist X) u v = u * v * EPoly X u v := by
  unfold EPoly tateTwist;
  rw [ Finset.sum_range_succ' ];
  rw [ Finset.sum_congr rfl fun i hi => Finset.sum_range_succ' _ _ ];
  simp +decide [ pow_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-! ## Serre duality and the functional equation -/

/-- **Serre duality** for a diamond of dimension `n`: `h^{p,q} = h^{n-p,n-q}` on
the support `0 ≤ p, q ≤ n`. -/
def HodgeDiamond.SerreDual (X : HodgeDiamond) : Prop :=
  ∀ p q, p ≤ X.dim → q ≤ X.dim → X.h p q = X.h (X.dim - p) (X.dim - q)

/-
!-- comment -- !--
Over a field, factor (uv)ⁿ inside the double sum, rewrite u^{n-p} = uⁿ·u⁻ᵖ etc.,
then reindex p ↦ n-p, q ↦ n-q (`Finset.sum_range_reflect`) and apply Serre
duality; the sign identity (-1)^{(n-p)+(n-q)} = (-1)^{p+q} closes it.
!-- comment -- !--

**Serre / Poincaré functional equation.**  For a Serre-dual diamond of dimension
`n` over a field, `E(X; u, v) = (uv)ⁿ E(X; u⁻¹, v⁻¹)`.  (Serre duality alone
suffices; `Supported` is not needed since `E` only ranges over `0 … n`.)
-/
theorem epoly_serre_functional_equation {K : Type*} [Field K]
    (X : HodgeDiamond) (hS : X.SerreDual)
    (u v : K) (hu : u ≠ 0) (hv : v ≠ 0) :
    EPoly X u v = (u * v) ^ X.dim * EPoly X u⁻¹ v⁻¹ := by
  unfold EPoly;
  -- Apply the Serre duality to rewrite the sum.
  have h_sum : ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1), (-1 : K) ^ (p + q) * (X.h p q : K) * u ^ p * v ^ q = ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1), (-1 : K) ^ ((X.dim - p) + (X.dim - q)) * (X.h (X.dim - p) (X.dim - q) : K) * u ^ (X.dim - p) * v ^ (X.dim - q) := by
    apply Finset.sum_bij (fun p _ => X.dim - p);
    · exact fun a ha => Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.sub_le _ _ ) );
    · grind;
    · exact fun b hb => ⟨ X.dim - b, Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.sub_le _ _ ) ), Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hb ) ⟩;
    · intro p hp; rw [ ← Finset.sum_flip ] ; refine' Finset.sum_congr rfl fun q hq => _ ; simp +decide [ Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hp ), Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hq ) ] ;
  convert h_sum using 1;
  simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, pow_add, hu, hv, hS ];
  refine' Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => _;
  rw [ hS i j ( Finset.mem_range_succ_iff.mp hi ) ( Finset.mem_range_succ_iff.mp hj ) ] ; simp +decide [ hu, hv, mul_pow, mul_assoc, mul_comm, mul_left_comm, pow_add, pow_sub₀, Finset.mem_range_succ_iff.mp hi, Finset.mem_range_succ_iff.mp hj ] ; ring;
  norm_num [ pow_mul' ]

/-
!-- comment -- !--
Specialise the functional equation to `u = v = t`: `(t·t)ⁿ = t^{2n}` and
`P(X;t) = E(X;t,t)` give the palindrome.
!-- comment -- !--

**Poincaré palindrome.**  Under Serre duality the one-variable Poincaré
polynomial is palindromic: `P(X; t) = t^{2n} P(X; t⁻¹)`.
-/
theorem poincare_serre_palindrome {K : Type*} [Field K]
    (X : HodgeDiamond) (hS : X.SerreDual)
    (t : K) (ht : t ≠ 0) :
    poincarePoly X t = t ^ (2 * X.dim) * poincarePoly X t⁻¹ := by
  convert epoly_serre_functional_equation X hS t t ht ht using 1 ; ring;
  rfl

end HodgeEPolynomial