import Mathlib

/-!
# Quadratic Reciprocity: Comparative Proof Architecture

A verified comparative study of quadratic reciprocity proofs. We define
`ReciprocityWitness` and `QRParityModel` structures encoding different proof
mechanisms, prove the Eisenstein floor-sum identity, supplementary laws,
cross-proof equivalence, and lattice-region connections.

## Main definitions

* `ReciprocityWitness` — a structure encoding a proof method for QR
* `QRParityModel` — a parity-extraction model for reciprocity proofs
* `eisensteinFloorSum` — the floor-sum in Eisenstein's proof
* `upperHalfResidueCount` — the count used in Gauss's lemma
* `eisensteinParity` / `gaussParity` — parity extractors
* `reciprocityLatticeRegion` — the lattice region for Eisenstein's proof

## Main results

* `eisenstein_floor_identity` — the Eisenstein floor-sum identity
* `legendre_minus_one` — first supplementary law
* `legendre_two` — second supplementary law
* `quadratic_reciprocity_eisenstein` — QR via Eisenstein
* `eisenstein_gauss_parity_equiv` — cross-proof equivalence
* `reciprocity_lattice_region_card` — lattice region = floor sum
* `quadratic_reciprocity_methods_agree` — all witnesses agree

## Keywords

quadratic character, lattice-point parity, Gauss sums, reciprocity law,
computational number theory, proof interoperability, arithmetic geometry
-/

noncomputable section

open Finset BigOperators

/-! ### Proof witness structures -/

/-- A `ReciprocityWitness` encodes a proof mechanism for quadratic reciprocity. -/
structure ReciprocityWitness where
  signFn : ℕ → ℕ → ℤ
  sound :
    ∀ {p q : ℕ}, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 →
      signFn p q = (-1) ^ ((p - 1) / 2 * ((q - 1) / 2))

/-- A `QRParityModel` extracts a `ZMod 2` parity from a pair of primes. -/
structure QRParityModel where
  parity : ℕ → ℕ → ZMod 2
  reciprocity_parity :
    ∀ {p q : ℕ}, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 →
      parity p q = (((p - 1) / 2 * ((q - 1) / 2) : ℕ) : ZMod 2)

/-! ### Core definitions -/

/-- The Eisenstein floor sum: `∑_{i=1}^{(p-1)/2} ⌊iq/p⌋`. -/
def eisensteinFloorSum (p q : ℕ) : ℕ :=
  ∑ i ∈ Finset.Icc 1 (p / 2), (i * q) / p

/-- The Eisenstein parity: parity of combined floor sums. -/
def eisensteinParity (p q : ℕ) : ZMod 2 :=
  (eisensteinFloorSum p q + eisensteinFloorSum q p : ℕ)

/-- Count of `k ∈ [1, (p-1)/2]` with `(a*k) mod p > p/2`. -/
def upperHalfResidueCount (a p : ℕ) : ℕ :=
  ((Finset.Icc 1 (p / 2)).filter (fun k => p / 2 < (a * k) % p)).card

/-- The Gauss parity for a pair of primes. -/
def gaussParity (p q : ℕ) : ZMod 2 :=
  (upperHalfResidueCount q p + upperHalfResidueCount p q : ℕ)

/-- Lattice points below the line `y = (q/p)x` in the half-rectangle. -/
def reciprocityLatticeRegion (p q : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.Icc 1 (p / 2) ×ˢ Finset.Icc 1 (q / 2)).filter (fun xy => xy.2 * p < xy.1 * q)

/-! ### Helper lemmas -/

lemma odd_div_two {p : ℕ} (hp : p % 2 = 1) : p / 2 = (p - 1) / 2 := by omega

lemma div_four_eq_div_two_mul {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) :
    (p - 1) * (q - 1) / 4 = (p - 1) / 2 * ((q - 1) / 2) := by
  obtain ⟨a, ha⟩ : 2 ∣ (p - 1) := by omega
  obtain ⟨b, hb⟩ : 2 ∣ (q - 1) := by omega
  rw [ha, hb, Nat.mul_div_cancel_left _ two_pos, Nat.mul_div_cancel_left _ two_pos]
  have : 2 * a * (2 * b) = a * b * 4 := by ring
  rw [this, Nat.mul_div_cancel _ (by norm_num : 0 < 4)]

lemma prime_odd_mod {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) : p % 2 = 1 :=
  Nat.odd_iff.mp (hp.odd_of_ne_two hp2)

/-! ## Theorem 1: Eisenstein Floor-Sum Identity -/

/-
**Eisenstein floor-sum identity.** For distinct odd primes `p` and `q`,
`∑_{i=1}^{(p-1)/2} ⌊iq/p⌋ + ∑_{j=1}^{(q-1)/2} ⌊jp/q⌋ = (p-1)(q-1)/4`.
-/
theorem eisenstein_floor_identity
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpodd : p % 2 = 1) (hqodd : q % 2 = 1) (hpq : p ≠ q) :
    eisensteinFloorSum p q + eisensteinFloorSum q p = (p - 1) * (q - 1) / 4 := by
  -- By definition of $eisensteinFloorSum$, we can rewrite the left-hand side of the equation as follows:
  have h_sum_eq : eisensteinFloorSum p q + eisensteinFloorSum q p = (∑ i ∈ Finset.Icc 1 (p / 2), (∑ j ∈ Finset.Icc 1 (q / 2), if j * p < i * q then 1 else 0)) + (∑ i ∈ Finset.Icc 1 (q / 2), (∑ j ∈ Finset.Icc 1 (p / 2), if j * q < i * p then 1 else 0)) := by
    refine' congrArg₂ ( · + · ) _ _ <;> refine' Finset.sum_congr rfl fun i hi => _ <;> simp +decide [ *, Nat.div_eq_of_lt ];
    · -- Let's simplify the set on the right-hand side.
      have h_set_eq : {x ∈ Finset.Icc 1 (q / 2) | x * p < i * q} = Finset.Icc 1 ((i * q) / p) := by
        ext x;
        simp +zetaDelta at *;
        constructor <;> intro h <;> rw [ Nat.le_div_iff_mul_le hp.pos ] at *;
        · exact ⟨ h.1.1, h.2.le ⟩;
        · refine' ⟨ ⟨ h.1, Nat.le_div_iff_mul_le zero_lt_two |>.2 _ ⟩, lt_of_le_of_ne h.2 _ ⟩;
          · nlinarith [ Nat.div_mul_le_self p 2 ];
          · intro H; have := Nat.dvd_of_mod_eq_zero ( show ( i * q ) % p = 0 from Nat.mod_eq_zero_of_dvd <| H ▸ dvd_mul_left _ _ ) ; simp_all +decide [ Nat.Prime.dvd_mul ] ;
            exact absurd ( this.resolve_right ( by rw [ Nat.prime_dvd_prime_iff_eq ] <;> tauto ) ) ( Nat.not_dvd_of_pos_of_lt hi.1 ( by linarith [ Nat.div_mul_le_self p 2 ] ) );
      aesop;
    · rw [ show { x ∈ Finset.Icc 1 ( p / 2 ) | x * q < i * p } = Finset.Icc 1 ( i * p / q ) from ?_ ];
      · norm_num;
      · ext x;
        simp +zetaDelta at *;
        constructor <;> intro h;
        · exact ⟨ h.1.1, Nat.le_div_iff_mul_le hq.pos |>.2 <| by linarith ⟩;
        · refine' ⟨ ⟨ h.1, _ ⟩, _ ⟩;
          · rw [ Nat.le_div_iff_mul_le hq.pos ] at *;
            rw [ Nat.le_div_iff_mul_le ] <;> nlinarith [ Nat.div_mul_le_self q 2 ];
          · by_contra h_contra;
            -- If $x * q = i * p$, then $p$ divides $x * q$, and since $p$ is prime, $p$ must divide $x$ or $q$.
            have h_div : p ∣ x ∨ p ∣ q := by
              exact hp.dvd_mul.mp ( Nat.dvd_of_mod_eq_zero ( by rw [ Nat.mod_eq_zero_of_dvd ] ; exact ⟨ i, by nlinarith [ Nat.div_mul_le_self ( i * p ) q ] ⟩ ) );
            exact absurd ( h_div.resolve_right ( by rw [ Nat.prime_dvd_prime_iff_eq ] <;> tauto ) ) ( Nat.not_dvd_of_pos_of_lt h.1 ( by nlinarith [ Nat.div_mul_le_self ( i * p ) q, Nat.div_mul_le_self q 2 ] ) );
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : (∑ i ∈ Finset.Icc 1 (p / 2), (∑ j ∈ Finset.Icc 1 (q / 2), if j * p < i * q then 1 else 0)) + (∑ i ∈ Finset.Icc 1 (q / 2), (∑ j ∈ Finset.Icc 1 (p / 2), if j * q < i * p then 1 else 0)) = (∑ i ∈ Finset.Icc 1 (p / 2), (∑ j ∈ Finset.Icc 1 (q / 2), if j * p ≠ i * q then 1 else 0)) := by
    rw [ Finset.sum_comm ];
    rw [ ← Finset.sum_add_distrib, Finset.sum_comm ];
    exact Finset.sum_congr rfl fun i hi => by rw [ ← Finset.sum_add_distrib ] ; exact Finset.sum_congr rfl fun j hj => by split_ifs <;> first | linarith | omega;
  -- Since $p$ and $q$ are distinct primes, $j * p \neq i * q$ for all $i \in [1, p/2]$ and $j \in [1, q/2]$.
  have h_distinct : ∀ i ∈ Finset.Icc 1 (p / 2), ∀ j ∈ Finset.Icc 1 (q / 2), j * p ≠ i * q := by
    intros i hi j hj h_eq
    have h_div : p ∣ i * q := by
      exact h_eq ▸ dvd_mul_left _ _
    have h_div' : q ∣ j * p := by
      exact h_eq.symm ▸ dvd_mul_left _ _
    have h_div_p : p ∣ i := by
      exact Or.resolve_right ( hp.dvd_mul.mp h_div ) ( by intro t; have := Nat.prime_dvd_prime_iff_eq hp hq; tauto )
    have h_div_q : q ∣ j := by
      exact absurd ( Nat.le_of_dvd ( by linarith [ Finset.mem_Icc.mp hi ] ) h_div_p ) ( by linarith [ Finset.mem_Icc.mp hi, Nat.div_mul_le_self p 2 ] )
    have h_contra : i ≥ p := by
      exact Nat.le_of_dvd ( Finset.mem_Icc.mp hi |>.1 ) h_div_p
    have h_contra' : j ≥ q := by
      exact Nat.le_of_dvd ( Finset.mem_Icc.mp hj |>.1 ) h_div_q
    linarith [Finset.mem_Icc.mp hi, Finset.mem_Icc.mp hj, Nat.div_mul_le_self p 2, Nat.div_mul_le_self q 2];
  simp_all +decide [ Finset.sum_ite ];
  exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_four ( by nlinarith only [ Nat.sub_add_cancel hp.pos, Nat.sub_add_cancel hq.pos, Nat.mod_add_div p 2, Nat.mod_add_div q 2, hpodd, hqodd ] ) )

/-! ## Theorem 2: First Supplementary Law -/

/-- **First supplementary law.** `legendreSym p (-1) = (-1)^((p-1)/2)`. -/
theorem legendre_minus_one (p : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2) :
    legendreSym p (-1) = (-1) ^ ((p - 1) / 2) := by
  rw [legendreSym.at_neg_one]
  · rw [ZMod.χ₄_eq_neg_one_pow, odd_div_two]
    · exact Nat.Prime.eq_two_or_odd (Fact.out : Nat.Prime p) |> Or.resolve_left <| hp2
    · exact Nat.Prime.eq_two_or_odd (Fact.out : Nat.Prime p) |> Or.resolve_left <| hp2
  · assumption

/-! ## Theorem 3: Second Supplementary Law -/

/-
**Second supplementary law.** `legendreSym p 2 = (-1)^((p²-1)/8)`.
-/
theorem legendre_two (p : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2) :
    legendreSym p 2 = (-1) ^ ((p * p - 1) / 8) := by
  convert legendreSym.at_two hp2 using 1;
  rw [ ZMod.χ₈_nat_eq_if_mod_eight ];
  rw [ ← Nat.mod_add_div p 8 ] ; have := Nat.mod_lt p ( by decide : 0 < 8 ) ; interval_cases _ : p % 8 <;> simp +decide [ *, Nat.add_mod, Nat.mul_mod ] ;
  all_goals have := Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) ; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 8 ) ];
  · ring_nf;
    norm_num [ add_assoc, Nat.add_div ];
    norm_num [ Nat.mul_div_assoc, Nat.mul_mod, Nat.pow_mod ];
    norm_num [ pow_add, pow_mul' ];
  · ring_nf;
    norm_num [ show 9 + p / 8 * 48 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 1 + p / 8 * 6 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
    norm_num [ pow_add, pow_mul' ];
  · ring_nf;
    norm_num [ show 25 + p / 8 * 80 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 3 + p / 8 * 10 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
    norm_num [ pow_add, pow_mul' ];
  · ring_nf;
    norm_num [ show 49 + p / 8 * 112 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 6 + p / 8 * 14 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
    norm_num [ pow_add, pow_mul' ]

/-! ## Theorem 4: Quadratic Reciprocity (Eisenstein form) -/

/-- **Quadratic reciprocity.** Restated with `(p-1)/2` notation. -/
theorem quadratic_reciprocity_eisenstein
    (p q : ℕ) [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q (p : ℤ) * legendreSym p (q : ℤ) =
      (-1) ^ ((p - 1) / 2 * ((q - 1) / 2)) := by
  rw [← odd_div_two (prime_odd_mod (Fact.out) hp2),
      ← odd_div_two (prime_odd_mod (Fact.out) hq2)]
  exact legendreSym.quadratic_reciprocity hp2 hq2 hpq

/-! ## Theorem 5: Lattice Region Connection -/

/-
The lattice region count equals the Eisenstein floor sum (for coprime p, q).
-/
theorem reciprocity_lattice_region_card
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    (reciprocityLatticeRegion p q).card = eisensteinFloorSum p q := by
  convert Finset.card_filter ( fun x : ℕ × ℕ => x.2 * p < x.1 * q ) ( Finset.Icc 1 ( p / 2 ) ×ˢ Finset.Icc 1 ( q / 2 ) ) using 1;
  erw [ Finset.sum_product ] ; simp +decide [ eisensteinFloorSum ];
  refine' Finset.sum_congr rfl fun x hx => _;
  rw [ show { x_1 ∈ Icc 1 ( q / 2 ) | x_1 * p < x * q } = Finset.Icc 1 ( x * q / p ) from ?_ ] ; simp +decide [ Finset.card_range ];
  ext y;
  simp +zetaDelta at *;
  constructor <;> intro h <;> rw [ Nat.le_div_iff_mul_le hp.pos ] at *;
  · exact ⟨ h.1.1, h.2.le ⟩;
  · refine' ⟨ ⟨ h.1, Nat.le_div_iff_mul_le zero_lt_two |>.2 _ ⟩, lt_of_le_of_ne h.2 _ ⟩;
    · nlinarith [ Nat.div_mul_le_self p 2 ];
    · intro H; have := congr_arg ( · % p ) H; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mod_eq_of_lt hp.one_lt, Nat.mod_eq_of_lt hq.one_lt ] at this;
      rw [ eq_comm ] at this; simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_mul, hq.dvd_mul ] ;
      exact absurd ( this.resolve_right ( by rw [ Nat.prime_dvd_prime_iff_eq ] <;> tauto ) ) ( Nat.not_dvd_of_pos_of_lt hx.1 ( by linarith [ Nat.div_mul_le_self p 2 ] ) )

/-- **Reciprocity as lattice-point parity.** -/
theorem reciprocity_lattice_region_parity
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    ((reciprocityLatticeRegion p q).card + (reciprocityLatticeRegion q p).card) % 2 =
      ((p - 1) / 2 * ((q - 1) / 2)) % 2 := by
  rw [reciprocity_lattice_region_card p q hp hq hpq,
      reciprocity_lattice_region_card q p hq hp (Ne.symm hpq)]
  rw [eisenstein_floor_identity p q hp hq (prime_odd_mod hp hp2) (prime_odd_mod hq hq2) hpq]
  rw [div_four_eq_div_two_mul (prime_odd_mod hp hp2) (prime_odd_mod hq hq2)]

/-! ## Theorem 6: Cross-Proof Equivalence -/

/-
**Eisenstein–Gauss parity equivalence.** Both parities equal the same
reciprocity exponent mod 2, so they must be equal.
-/
set_option maxHeartbeats 800000 in
theorem eisenstein_gauss_parity_equiv
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    eisensteinParity p q = gaussParity p q := by
  unfold eisensteinParity gaussParity;
  haveI := Fact.mk hp; haveI := Fact.mk hq; ( rw [ ZMod.natCast_eq_natCast_iff ] at *; simp_all +decide [ Nat.ModEq, Nat.mod_mod ] ; );
  -- By Gauss's Lemma, we know that the Legendre symbol $(a/p)$ is equal to $(-1)^{N(a,p)}$, where $N(a,p)$ is the number of integers $k$ in the range $1$ to $(p-1)/2$ such that $ak \mod p > p/2$.
  have h_gauss_lemma : ∀ {p : ℕ} [Fact (Nat.Prime p)] (a : ℤ), ¬(p : ℤ) ∣ a → (legendreSym p a) = (-1) ^ (upperHalfResidueCount (Int.natAbs (a % p)) p) := by
    intros p hp a ha;
    have := @ZMod.gauss_lemma p;
    by_cases h : p = 2 <;> simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ];
    · simp +decide [ legendreSym, ha ];
      rw [ ← Int.emod_add_mul_ediv a 2, ha ] ; norm_num [ ZMod, quadraticCharFun ];
      norm_cast ; simp_all +decide [ ZMod ];
      grind;
    · refine' congr_arg _ ( Finset.card_bij ( fun x hx => x ) _ _ _ ) <;> simp +decide [ ZMod.val_mul ];
      · intro x hx₁ hx₂ hx₃; use ⟨ hx₁, hx₂ ⟩ ; simp_all +decide [ ← ZMod.val_natCast, Nat.mod_eq_of_lt ] ;
        simp_all +decide [ abs_of_nonneg ( Int.emod_nonneg _ ( Nat.cast_ne_zero.mpr hp.1.ne_zero ) ), ZMod.val_mul ];
      · intro b hb₁ hb₂ hb₃; rw [ ← ZMod.val_natCast ] at *; simp_all +decide [ ZMod.val_mul ] ;
        simp_all +decide [ abs_of_nonneg ( Int.emod_nonneg _ ( Nat.cast_ne_zero.mpr hp.1.ne_zero ) ), ZMod.val_mul ];
  have h_eisenstein_gauss : ∀ {p q : ℕ} [Fact (Nat.Prime p)] [Fact (Nat.Prime q)] (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q), eisensteinFloorSum p q % 2 = upperHalfResidueCount q p % 2 := by
    intros p q hp hq hp2 hq2 hpq
    have h_eisenstein_gauss : eisensteinFloorSum p q % 2 = (upperHalfResidueCount q p) % 2 := by
      have h_legendre : legendreSym p q = (-1) ^ (eisensteinFloorSum p q) := by
        have := @ZMod.eisenstein_lemma p;
        convert this hp2 ( show q % 2 = 1 from hq.1.eq_two_or_odd.resolve_left hq2 ) ( show ( q : ZMod p ) ≠ 0 from by rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact fun h => hpq <| by have := Nat.prime_dvd_prime_iff_eq hp.1 hq.1; tauto ) using 1
      have h_legendre_gauss : legendreSym p q = (-1) ^ (upperHalfResidueCount q p) := by
        convert h_gauss_lemma q _ using 1;
        · norm_cast;
          unfold upperHalfResidueCount; simp +decide [ Nat.mul_mod ] ;
        · exact_mod_cast fun h => hpq <| Nat.prime_dvd_prime_iff_eq hp.1 hq.1 |>.1 h;
      rcases Nat.even_or_odd' ( eisensteinFloorSum p q ) with ⟨ k, hk | hk ⟩ <;> rcases Nat.even_or_odd' ( upperHalfResidueCount q p ) with ⟨ l, hl | hl ⟩ <;> simp_all +decide [ Nat.even_iff ];
    exact h_eisenstein_gauss;
  have h_eisenstein_gauss_symm : ∀ {p q : ℕ} [Fact (Nat.Prime p)] [Fact (Nat.Prime q)] (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q), eisensteinFloorSum q p % 2 = upperHalfResidueCount p q % 2 := by
    grind;
  haveI := Fact.mk hp; haveI := Fact.mk hq; simp_all +decide [ Nat.add_mod ] ;

/-! ## Proof Witness Instances -/

/-- The Eisenstein proof mechanism as a `ReciprocityWitness`. -/
def eisensteinWitness : ReciprocityWitness where
  signFn p q := (-1) ^ (eisensteinFloorSum p q + eisensteinFloorSum q p)
  sound := by
    intro p q hp hq hpq hp2 hq2
    congr 1
    rw [eisenstein_floor_identity p q hp hq (prime_odd_mod hp hp2) (prime_odd_mod hq hq2) hpq,
        div_four_eq_div_two_mul (prime_odd_mod hp hp2) (prime_odd_mod hq hq2)]

/-
The Gauss-lemma proof mechanism as a `ReciprocityWitness`.
-/
def gaussWitness : ReciprocityWitness where
  signFn p q := (-1) ^ (upperHalfResidueCount q p + upperHalfResidueCount p q)
  sound := by
    intros p q hp hq hpq hp2 hq2;
    -- Since the sum of the upper half residues and the Eisenstein floor sums are congruent modulo 2, their parities are equal.
    have h_parity_congr : (upperHalfResidueCount q p + upperHalfResidueCount p q) % 2 = ((p - 1) / 2 * ((q - 1) / 2)) % 2 := by
      convert eisenstein_gauss_parity_equiv p q hp hq hp2 hq2 hpq using 1;
      unfold eisensteinParity gaussParity;
      rw [ eisenstein_floor_identity p q hp hq ( prime_odd_mod hp hp2 ) ( prime_odd_mod hq hq2 ) hpq ];
      rw [ div_four_eq_div_two_mul ( prime_odd_mod hp hp2 ) ( prime_odd_mod hq hq2 ) ];
      erw [ ZMod.natCast_eq_natCast_iff ] ; tauto;
    rw [ ← Nat.mod_add_div ( upperHalfResidueCount q p + upperHalfResidueCount p q ) 2, ← Nat.mod_add_div ( ( p - 1 ) / 2 * ( ( q - 1 ) / 2 ) ) 2, h_parity_congr ] ; norm_num [ pow_add, pow_mul ] ;

/-- The direct Legendre-symbol product as a `ReciprocityWitness`. -/
def legendreWitness : ReciprocityWitness where
  signFn p q := (-1) ^ ((p - 1) / 2 * ((q - 1) / 2))
  sound := fun _ _ _ _ _ => rfl

/-- **All three proof witnesses agree.** -/
theorem quadratic_reciprocity_methods_agree
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    eisensteinWitness.signFn p q = gaussWitness.signFn p q ∧
    gaussWitness.signFn p q = legendreWitness.signFn p q := by
  constructor
  · rw [eisensteinWitness.sound hp hq hpq hp2 hq2,
        gaussWitness.sound hp hq hpq hp2 hq2]
  · rw [gaussWitness.sound hp hq hpq hp2 hq2]; rfl

/-- The Eisenstein parity model. -/
def eisensteinParityModel : QRParityModel where
  parity := eisensteinParity
  reciprocity_parity := by
    intro p q hp hq hpq hp2 hq2
    simp only [eisensteinParity]
    have h := eisenstein_floor_identity p q hp hq
      (prime_odd_mod hp hp2) (prime_odd_mod hq hq2) hpq
    rw [h, div_four_eq_div_two_mul (prime_odd_mod hp hp2) (prime_odd_mod hq hq2)]

/-
The Gauss parity model.
-/
def gaussParityModel : QRParityModel where
  parity := gaussParity
  reciprocity_parity := by
    intro p q hp hq hpq hp2 hq2; rw [ ← eisenstein_gauss_parity_equiv p q hp hq hp2 hq2 hpq ] ;
    convert eisensteinParityModel.reciprocity_parity hp hq hpq hp2 hq2 using 1

end