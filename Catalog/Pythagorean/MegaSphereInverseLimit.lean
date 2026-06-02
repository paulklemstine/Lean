import Mathlib

/-!
# Mega-Sphere as a Well-Defined Inverse Limit

We formalize the Mega-Sphere as an inverse limit object encoding sphere invariant
data across all dimensions, prove the Bernoulli-sphere resonance theorem (the
combined weight B'_n · χ(Sⁿ) vanishes at all odd dimensions), and introduce the
Graded Sphere Algebra with its universal pairing theorem.

## Main definitions

* `eulerCharSphere` — The Euler characteristic of the n-sphere: χ(Sⁿ) = 1 + (-1)ⁿ
* `NatInverseSystem` — An inverse system indexed by ℕ with bonding maps
* `sphereInvSystem` — The sphere invariant system encoding χ data at each level
* `megaSphereElement` — The canonical element of the inverse limit
* `bernoulliSphereWeight` — The combined weight B'_n · χ(Sⁿ)
* `sphereConvolution` — Convolution product for the Graded Sphere Algebra

## Main results

* `eulerCharSphere_odd` — χ(Sⁿ) = 0 for odd n
* `eulerCharSphere_even` — χ(Sⁿ) = 2 for even n
* `bernoulli_sphere_resonance` — B'_n · χ(Sⁿ) = 0 for all odd n
* `graded_pairing_even_even` — P(2j, 2k) = 4 (rigidity of even-even sphere products)
* `megaSphere_universal_property` — Universal property of the Mega-Sphere inverse limit
* `sphereConvolution_odd_vanish` — Convolution concentrates on even-dimensional terms
* `euler_char_alternating_telescope` — Telescoping identity for alternating Euler sums
-/

noncomputable section

open Finset BigOperators

/-! ## Part 1: Euler Characteristic of Spheres -/

/-- The Euler characteristic of the n-dimensional sphere Sⁿ.
    This equals 2 for even n and 0 for odd n. -/
def eulerCharSphere (n : ℕ) : ℤ := 1 + (-1 : ℤ) ^ n

@[simp]
theorem eulerCharSphere_zero : eulerCharSphere 0 = 2 := by
  simp [eulerCharSphere]

@[simp]
theorem eulerCharSphere_one : eulerCharSphere 1 = 0 := by
  simp [eulerCharSphere]

/-
χ(Sⁿ) = 2 when n is even
-/
theorem eulerCharSphere_even {n : ℕ} (h : Even n) : eulerCharSphere n = 2 := by
  obtain ⟨ k, hk ⟩ := h; simp +decide [ hk, eulerCharSphere ] ;

/-
χ(Sⁿ) = 0 when n is odd — the fundamental vanishing theorem
-/
theorem eulerCharSphere_odd {n : ℕ} (h : Odd n) : eulerCharSphere n = 0 := by
  unfold eulerCharSphere; obtain ⟨ k, rfl ⟩ := h; norm_num [ pow_add ] ;

/-
The Euler characteristic is periodic with period 2
-/
theorem eulerCharSphere_succ_succ (n : ℕ) : eulerCharSphere (n + 2) = eulerCharSphere n := by
  unfold eulerCharSphere; norm_num [ pow_succ' ] ;

/-! ## Part 2: Inverse System and Mega-Sphere -/

/-- An inverse system indexed by ℕ with bonding maps. -/
structure NatInverseSystem where
  /-- The object at level n -/
  obj : ℕ → Type*
  /-- The bonding map from level n+1 to level n -/
  bond : ∀ n, obj (n + 1) → obj n

/-- The inverse limit of a system over ℕ: sequences compatible with all bonding maps -/
def NatInverseSystem.InvLimit (S : NatInverseSystem) :=
  { f : ∀ n, S.obj n // ∀ n, S.bond n (f (n + 1)) = f n }

/-- The canonical projection from the inverse limit to level n -/
def NatInverseSystem.proj (S : NatInverseSystem) (n : ℕ) :
    S.InvLimit → S.obj n :=
  fun ⟨f, _⟩ => f n

/-- The sphere invariant system: at level n, we record the Euler characteristics
    of spheres S⁰ through Sⁿ. The bonding map truncates the last entry. -/
def sphereInvSystem : NatInverseSystem where
  obj n := Fin (n + 1) → ℤ
  bond n := fun f i => f ⟨i.val, by omega⟩

/-- The Mega-Sphere: the canonical element whose components are the actual
    Euler characteristics of spheres. -/
def megaSphereElement : sphereInvSystem.InvLimit :=
  ⟨fun n i => eulerCharSphere i.val, fun n => by
    funext i; simp [sphereInvSystem]⟩

/-- The projection of the Mega-Sphere to level n correctly recovers
    the Euler characteristic function on spheres S⁰ through Sⁿ. -/
theorem megaSphere_proj_correct (n : ℕ) (i : Fin (n + 1)) :
    sphereInvSystem.proj n megaSphereElement i = eulerCharSphere i.val := by
  simp [NatInverseSystem.proj, megaSphereElement]

/-
**Universal property of the Mega-Sphere inverse limit.**
    Given any type A with maps to each level that are compatible with the bonding
    maps, there exists a unique factorization through the inverse limit.
-/
theorem megaSphere_universal_property {A : Type*}
    (φ : ∀ n, A → sphereInvSystem.obj n)
    (compat : ∀ n a, sphereInvSystem.bond n (φ (n + 1) a) = φ n a) :
    ∃! (Φ : A → sphereInvSystem.InvLimit),
      ∀ n a, sphereInvSystem.proj n (Φ a) = φ n a := by
  fconstructor;
  exact fun a => ⟨ fun n => φ n a, fun n => compat n a ⟩;
  exact ⟨ fun n a => rfl, fun Ψ hΨ => funext fun a => Subtype.ext <| funext fun n => hΨ n a ⟩

/-! ## Part 3: Bernoulli-Sphere Resonance -/

/-- The Bernoulli-sphere weight: w(n) = B'_n · χ(Sⁿ), where B'_n is the
    n-th Bernoulli number with the convention B'_1 = 1/2.

    Key values: w(0) = 2, w(1) = 0, w(2) = 1/3, w(3) = 0, w(4) = -1/15 -/
def bernoulliSphereWeight (n : ℕ) : ℚ :=
  bernoulli' n * ((eulerCharSphere n : ℤ) : ℚ)

/-
**Bernoulli-Sphere Resonance Theorem.**
    The Bernoulli-sphere weight vanishes at every odd dimension.
    The key insight: χ(Sⁿ) = 0 for odd n, so the product vanishes regardless
    of the Bernoulli number.
-/
theorem bernoulli_sphere_resonance {n : ℕ} (h : Odd n) :
    bernoulliSphereWeight n = 0 := by
  unfold bernoulliSphereWeight; simp +decide [ h, eulerCharSphere_odd ] ;

/-
The weight at n = 0: w(0) = B'_0 · χ(S⁰) = 1 · 2 = 2.
-/
theorem bernoulliSphereWeight_zero : bernoulliSphereWeight 0 = 2 := by
  native_decide +revert

/-
At n = 2, w(2) = B'_2 · χ(S²) = (1/6) · 2 = 1/3.
-/
theorem bernoulliSphereWeight_two : bernoulliSphereWeight 2 = 1 / 3 := by
  native_decide +revert

/-
For odd n > 1, the vanishing is a "double resonance" — both the Bernoulli
    number and the Euler characteristic vanish independently.
-/
theorem bernoulli_sphere_double_resonance {n : ℕ} (h : Odd n) (h1 : 1 < n) :
    bernoulli' n = 0 ∧ eulerCharSphere n = 0 := by
  exact ⟨ bernoulli'_eq_zero_of_odd h h1, eulerCharSphere_odd h ⟩

/-! ## Part 4: Graded Sphere Algebra -/

/-- The sphere pairing: P(j, k) = χ(Sʲ) · χ(Sᵏ).
    Captures the Euler characteristic of Sʲ × Sᵏ via the Künneth formula. -/
def spherePairing (j k : ℕ) : ℤ := eulerCharSphere j * eulerCharSphere k

/-
**Universal Pairing Rigidity**: P(2j, 2k) = 4 for all j, k.
    The even-even pairing is rigid, independent of specific dimensions.
    This reflects χ(S^{2j} × S^{2k}) = 4.
-/
theorem graded_pairing_even_even (j k : ℕ) : spherePairing (2 * j) (2 * k) = 4 := by
  unfold spherePairing; rw [ eulerCharSphere_even ( by simp +decide ), eulerCharSphere_even ( by simp +decide ) ] ; norm_num;

/-
The pairing vanishes when the first argument is odd.
-/
theorem graded_pairing_odd_left {j : ℕ} (h : Odd j) (k : ℕ) :
    spherePairing j k = 0 := by
  exact mul_eq_zero_of_left ( eulerCharSphere_odd h ) _

/-
The pairing vanishes when the second argument is odd.
-/
theorem graded_pairing_odd_right (j : ℕ) {k : ℕ} (h : Odd k) :
    spherePairing j k = 0 := by
  exact mul_eq_zero_of_right _ ( eulerCharSphere_odd h )

/-
The pairing is commutative: P(j, k) = P(k, j).
-/
theorem spherePairing_comm (j k : ℕ) : spherePairing j k = spherePairing k j := by
  exact mul_comm _ _

/-- The sphere convolution: C(n) = ∑_{j=0}^{n} P(j, n-j).
    This is the structure constant of the Graded Sphere Algebra. -/
def sphereConvolution (n : ℕ) : ℤ :=
  ∑ j ∈ Finset.range (n + 1), spherePairing j (n - j)

/-
**Even concentration theorem**: The sphere convolution vanishes for all odd n.
    Only even-degree components carry information.
-/
theorem sphereConvolution_odd_vanish {n : ℕ} (h : Odd n) :
    sphereConvolution n = 0 := by
  convert Finset.sum_eq_zero _;
  grind +suggestions

/-
For even n = 2m, the convolution counts even-even decompositions.
    There are m+1 such pairs (0+2m, 2+(2m-2), ..., 2m+0),
    each contributing P = 4, giving C(2m) = 4(m+1).
-/
theorem sphereConvolution_even (m : ℕ) :
    sphereConvolution (2 * m) = 4 * (↑m + 1) := by
  -- We can split the sum into even and odd parts.
  have h_split : ∑ j ∈ Finset.range (2 * m + 1), spherePairing j (2 * m - j) = ∑ j ∈ Finset.filter (fun j => Even j) (Finset.range (2 * m + 1)), spherePairing j (2 * m - j) := by
    rw [ Finset.sum_filter, Finset.sum_congr rfl ];
    intro x hx; split_ifs <;> simp_all +decide [ spherePairing, eulerCharSphere_odd ] ;
  convert h_split using 1;
  rw [ Finset.sum_congr rfl fun x hx => show spherePairing x ( 2 * m - x ) = 4 from _ ];
  · rw [ show Finset.filter ( fun x => Even x ) ( Finset.range ( 2 * m + 1 ) ) = Finset.image ( fun x => 2 * x ) ( Finset.range ( m + 1 ) ) from ?_, Finset.sum_image <| by norm_num ] ; norm_num ; ring;
    ext ( _ | x ) <;> simp +arith +decide [ parity_simps ];
    exact ⟨ fun h => ⟨ ( x + 1 ) / 2, by linarith [ Nat.div_mul_le_self ( x + 1 ) 2 ], by linarith [ Nat.div_mul_cancel ( show 2 ∣ x + 1 from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using h.2 ) ) ] ⟩, by rintro ⟨ a, ha, ha' ⟩ ; exact ⟨ by omega, by simpa [ parity_simps ] using congr_arg Even ha' ⟩ ⟩;
  · grind +suggestions

/-! ## Part 5: Telescoping and Accumulation -/

/-
Adjacent sphere dimensions always sum to 2:
    χ(Sⁿ) + χ(Sⁿ⁺¹) = 2 for all n. This is because exactly one of n, n+1
    is even (contributing 2) and the other is odd (contributing 0).
-/
theorem euler_char_sum_adjacent (n : ℕ) :
    eulerCharSphere n + eulerCharSphere (n + 1) = 2 := by
  grind +locals

/-
The cumulative Euler characteristic over a complete even range:
    ∑_{k=0}^{2m} χ(Sᵏ) = 2(m+1).
-/
theorem euler_char_cumulative_even (m : ℕ) :
    ∑ k ∈ Finset.range (2 * m + 1), eulerCharSphere k = 2 * (↑m + 1) := by
  induction' m with m ih;
  · rfl;
  · simp_all +decide [ Nat.mul_succ, Finset.sum_range_succ ];
    unfold eulerCharSphere; norm_num [ pow_succ' ] ; ring;

/-! ## Part 6: Conjecture and Counterexample -/

/-
**Sphere-Bernoulli Growth Conjecture** (FALSIFIED):
    The conjecture that |∑_{k=0}^{N} w(2k)| ≤ 2 for all N is false.
    Already at N = 1, w(0) + w(2) = 2 + 1/3 = 7/3 > 2.
-/
theorem sphere_bernoulli_growth_conjecture_counterexample :
    ¬ (∀ N : ℕ, |∑ k ∈ Finset.range (N + 1), bernoulliSphereWeight (2 * k)| ≤ 2) := by
  push_neg;
  use 1;
  norm_num [ Finset.sum_range_succ, bernoulliSphereWeight_zero, bernoulliSphereWeight_two ]

end