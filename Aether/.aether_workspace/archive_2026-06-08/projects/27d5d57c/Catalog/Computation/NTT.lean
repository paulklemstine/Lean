import Mathlib

/-!
# Number Theoretic Transform (NTT) and Convolution

We formalize the Number Theoretic Transform over a commutative ring with
a primitive root of unity, and prove the fundamental convolution theorem:

1. **NTT definition** (`NTT`): The discrete Fourier transform over a ring.
2. **Convolution theorem** (`NTT_conv`): NTT diagonalizes cyclic convolution.
3. **Primitive root properties**: Key algebraic lemmas about roots of unity.

## Mathematical Content

The NTT of a sequence `a : Fin n → R` with respect to a primitive `n`-th
root of unity `ω` is defined by:

  `(NTT ω a) j = ∑ i, a i * ω ^ (i * j)`

The cyclic convolution of sequences `a, b : Fin n → R` is:

  `(cyclicConvolution a b) k = ∑ i, a i * b ((k - i) mod n)`

The convolution theorem states that pointwise multiplication in the
transform domain corresponds to cyclic convolution in the original domain.
-/

open Finset BigOperators

noncomputable section

/-! ## NTT Definition -/

/-- The Number Theoretic Transform (NTT) / Discrete Fourier Transform
of a sequence `a : Fin n → R` with respect to `ω`. -/
def NTT {R : Type*} [CommRing R] {n : ℕ} (ω : R) (a : Fin n → R) : Fin n → R :=
  fun j => ∑ i : Fin n, a i * ω ^ (i.val * j.val)

/-- Pointwise multiplication of two sequences. -/
def pointwiseMul {R : Type*} [Mul R] {n : ℕ} (a b : Fin n → R) : Fin n → R :=
  fun i => a i * b i

/-- Cyclic convolution of two sequences. -/
def cyclicConvolution {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (a b : Fin n → R) : Fin n → R :=
  fun k => ∑ i : Fin n, a i * b ⟨(k.val + n - i.val) % n, Nat.mod_lt _ hn⟩

/-- Circulant multiplication: multiply by a circulant matrix defined by `c`. -/
def circulantMul {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (c x : Fin n → R) : Fin n → R :=
  cyclicConvolution hn c x

/-! ## Primitive Root Properties -/

/-
Sum of powers of a primitive root vanishes: `∑ i, ω^(i*j) = 0` for `j ≠ 0 mod n`.
-/
theorem sum_primitiveRoot_powers {R : Type*} [CommRing R] [IsDomain R] {n : ℕ} (hn : 0 < n)
    (ω : R) (hω : ω ^ n = 1)
    (hprim : ∀ m : ℕ, 0 < m → m < n → ω ^ m ≠ 1)
    (j : Fin n) (hj : j.val ≠ 0) :
    ∑ i : Fin n, ω ^ (i.val * j.val) = 0 := by
  have h_sum_zero : ∀ (ζ : R), ζ^n = 1 → ζ ≠ 1 → ∑ i ∈ Finset.range n, ζ^i = 0 := by
    intro ζ hζ hζ'; have := geom_sum_mul ζ n; have := mul_ne_zero ( sub_ne_zero_of_ne hζ' ) ( sub_ne_zero_of_ne hζ' ) ; simp_all +decide ;
  convert h_sum_zero ( ω ^ j.val ) _ _ using 1 <;> simp_all +decide [ pow_mul' ];
  · rw [ Finset.sum_range ];
  · rw [ ← pow_mul, mul_comm, pow_mul, hω, one_pow ];
  · exact hprim _ ( Nat.pos_of_ne_zero hj ) j.2

/-
Sum of all `n`-th roots of unity equals `n` when `j = 0`.
-/
theorem sum_primitiveRoot_zero {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (ω : R) :
    ∑ i : Fin n, ω ^ (i.val * 0) = (n : R) := by
  aesop

/-! ## NTT Linearity -/

/-
NTT is linear: `NTT ω (a + b) = NTT ω a + NTT ω b`.
-/
theorem NTT_add {R : Type*} [CommRing R] {n : ℕ} (ω : R) (a b : Fin n → R) :
    NTT ω (a + b) = NTT ω a + NTT ω b := by
  exact funext fun i => by unfold NTT; simp +decide [ mul_add, add_mul, Finset.sum_add_distrib ] ;

/-
NTT of scalar multiple: `NTT ω (c • a) = c • NTT ω a`.
-/
theorem NTT_smul {R : Type*} [CommRing R] {n : ℕ} (ω : R) (c : R) (a : Fin n → R) :
    NTT ω (c • a) = c • NTT ω a := by
  exact funext fun j => by simp +decide [ NTT, Finset.mul_sum _ _ _ ] ; ac_rfl;

/-! ## Convolution Theorem -/

/-
**The Convolution Theorem for NTT**:
The NTT of the cyclic convolution equals the pointwise product of the NTTs.
This is the fundamental algebraic identity underlying FFT-based multiplication.
-/
theorem NTT_conv {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (ω : R) (hω : ω ^ n = 1)
    (a b : Fin n → R) :
    NTT ω (cyclicConvolution hn a b) = pointwiseMul (NTT ω a) (NTT ω b) := by
  unfold NTT pointwiseMul cyclicConvolution;
  simp +decide only [mul_comm, mul_sum, mul_left_comm, Finset.sum_mul _ _ _, mul_assoc];
  refine' funext fun j => Finset.sum_comm.trans ( Finset.sum_congr rfl fun i hi => _ );
  -- By changing the variable of summation, we can rewrite the sum.
  have h_change_var : ∑ x : Fin n, a i * (ω ^ (j.val * x.val) * b ⟨(x.val + n - i.val) % n, Nat.mod_lt _ hn⟩) = ∑ x : Fin n, a i * (ω ^ (j.val * (x.val + i.val)) * b x) := by
    apply Finset.sum_bij (fun x _ => ⟨(x.val + n - i.val) % n, Nat.mod_lt _ hn⟩);
    · exact fun _ _ => Finset.mem_univ _;
    · simp +decide [ Fin.ext_iff ];
      intro a₁ a₂ h; have := Nat.modEq_iff_dvd.1 h.symm; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
      obtain ⟨ k, hk ⟩ := this; rw [ Nat.cast_sub ( by linarith [ Fin.is_lt a₁, Fin.is_lt i ] ), Nat.cast_sub ( by linarith [ Fin.is_lt a₂, Fin.is_lt i ] ) ] at hk; norm_num at hk; nlinarith [ show k = 0 by nlinarith [ Fin.is_lt a₁, Fin.is_lt a₂, Fin.is_lt i ] ] ;
    · intro b hb
      use ⟨(b.val + i.val) % n, Nat.mod_lt _ hn⟩;
      simp +decide [ add_assoc, Nat.add_sub_assoc, Nat.mod_eq_of_lt ];
    · intro x hx
      have h_exp : ω ^ (j.val * (x.val + n - i.val) % n + j.val * i.val) = ω ^ (j.val * x.val) := by
        have h_exp : (j.val * (x.val + n - i.val) % n + j.val * i.val) % n = (j.val * x.val) % n := by
          simp +decide [ ← ZMod.natCast_eq_natCast_iff', Nat.cast_sub ( show ( i : ℕ ) ≤ x + n from by linarith [ Fin.is_lt i, Fin.is_lt x ] ) ];
          ring;
        rw [ ← Nat.mod_add_div ( ( j : ℕ ) * ( x + n - i ) % n + j * i ) n, ← Nat.mod_add_div ( ( j : ℕ ) * x ) n, h_exp ] ; simp +decide [ pow_add, pow_mul, hω ] ;
      simp_all +decide [ pow_add, pow_mul ];
      simp_all +decide [ ← pow_mul, Nat.mul_mod ];
      simp_all +decide [ ← h_exp, Nat.mod_eq_of_lt ];
      rw [ ← Nat.mod_add_div ( j * ( ( x + n - i ) % n ) ) n ] ; simp +decide [ pow_add, pow_mul, hω ] ;
  exact h_change_var.trans ( Finset.sum_congr rfl fun _ _ => by ring )

/-- NTT diagonalizes circulant multiplication. -/
theorem NTT_diagonalizes_circulant {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (ω : R) (hω : ω ^ n = 1)
    (c x : Fin n → R) :
    NTT ω (circulantMul hn c x) = pointwiseMul (NTT ω c) (NTT ω x) := by
  exact NTT_conv hn ω hω c x

/-! ## NTT as AlgorithmicCertificate (Divide and Conquer) -/

/-- The recursive cost model for NTT: computing NTT of size `2^k` requires
at most `k * 2^k` ring operations (the Cooley-Tukey bound). -/
def nttCost (k : ℕ) : ℕ := k * 2 ^ k

/-
The NTT cost satisfies the divide-and-conquer recurrence:
`T(2^(k+1)) ≤ 2 * T(2^k) + 2^(k+1)`.
-/
theorem nttCost_recurrence (k : ℕ) :
    nttCost (k + 1) ≤ 2 * nttCost k + 2 ^ (k + 1) := by
  unfold nttCost; ring; norm_num;

/-- The even-indexed subsequence of a sequence. -/
def evenSubseq {R : Type*} {n : ℕ} (a : Fin (2 * n) → R) : Fin n → R :=
  fun i => a ⟨2 * i.val, by omega⟩

/-- The odd-indexed subsequence of a sequence. -/
def oddSubseq {R : Type*} {n : ℕ} (a : Fin (2 * n) → R) : Fin n → R :=
  fun i => a ⟨2 * i.val + 1, by omega⟩

/-
The Cooley-Tukey butterfly: recombining even and odd NTTs.
-/
theorem cooley_tukey_decomposition {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (ω : R) (hω : ω ^ (2 * n) = 1)
    (a : Fin (2 * n) → R) (j : Fin (2 * n)) :
    NTT ω a j = NTT (ω ^ 2) (evenSubseq a) ⟨j.val % n, Nat.mod_lt _ hn⟩ +
      ω ^ j.val * NTT (ω ^ 2) (oddSubseq a) ⟨j.val % n, Nat.mod_lt _ hn⟩ := by
  unfold NTT evenSubseq oddSubseq;
  -- Split the sum into even and odd indexed terms.
  have h_split : ∑ i : Fin (2 * n), a i * ω ^ (i.val * j.val) = (∑ i : Fin n, a (⟨2 * i.val, by omega⟩) * ω ^ (2 * i.val * j.val)) + (∑ i : Fin n, a (⟨2 * i.val + 1, by omega⟩) * ω ^ ((2 * i.val + 1) * j.val)) := by
    rw [ show ( Finset.univ : Finset ( Fin ( 2 * n ) ) ) = Finset.image ( fun x : Fin n => ⟨ 2 * x, by linarith [ x.2 ] ⟩ : Fin n → Fin ( 2 * n ) ) Finset.univ ∪ Finset.image ( fun x : Fin n => ⟨ 2 * x + 1, by linarith [ x.2 ] ⟩ : Fin n → Fin ( 2 * n ) ) Finset.univ from ?_, Finset.sum_union ];
    · rw [ Finset.sum_image, Finset.sum_image ] <;> simp +decide [ Fin.ext_iff ];
      · exact fun x y h => by simpa [ Fin.ext_iff ] using h;
      · exact fun x y h => Fin.ext <| by simpa using congr_arg Fin.val h;
    · norm_num [ Finset.disjoint_right ];
      exact fun a x => ne_of_apply_ne ( fun x => x % 2 ) ( by norm_num [ Nat.add_mod, Nat.mul_mod ] );
    · ext ⟨ x, hx ⟩ ; simp +decide [ Nat.even_iff ] ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> simp +decide [ Nat.even_iff ] ;
      · exact Or.inl ⟨ ⟨ k, by linarith ⟩, rfl ⟩;
      · exact Or.inr ⟨ ⟨ k, by linarith ⟩, rfl ⟩;
  -- Since $\omega^{2n} = 1$, we have $\omega^{2ij} = (\omega^2)^{ij}$ and $\omega^{(2i+1)j} = \omega^j (\omega^2)^{ij}$.
  have h_exp : ∀ i : Fin n, ω ^ (2 * i.val * j.val) = (ω ^ 2) ^ (i.val * (j.val % n)) ∧ ω ^ ((2 * i.val + 1) * j.val) = ω ^ j.val * (ω ^ 2) ^ (i.val * (j.val % n)) := by
    intro i
    have h_exp : ω ^ (2 * i.val * j.val) = (ω ^ 2) ^ (i.val * (j.val % n)) := by
      rw [ ← Nat.mod_add_div j n ] ; ring_nf ; simp_all +decide [ pow_mul, pow_add ] ;
      simp_all +decide [ ← pow_mul, mul_assoc ];
      rw [ show ω ^ ( i.val * ( n * ( j.val / n * 2 ) ) ) = ( ω ^ ( 2 * n ) ) ^ ( i.val * ( j.val / n ) ) by ring, hω, one_pow, mul_one ]
    have h_exp' : ω ^ ((2 * i.val + 1) * j.val) = ω ^ j.val * (ω ^ 2) ^ (i.val * (j.val % n)) := by
      rw [ ← h_exp, add_mul, one_mul, pow_add ] ; ring
    exact ⟨h_exp, h_exp'⟩;
  simp_all +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ]

end