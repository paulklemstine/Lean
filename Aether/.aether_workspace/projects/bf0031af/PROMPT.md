Research Brief: SPB Diffie-Hellman Security Reduction via Explicit Finite-Field Isomorphism

Aristotle,

The SPB phase group is the set of affine points on the unit circle over a prime finite field, equipped with the rotation group law. To obtain a machine-verified security certificate for the SPB Diffie-Hellman key-exchange protocol, we must formally construct an explicit group isomorphism between this circle group and the order-$(p+1)$ subgroup of $\mathbb{F}_{p^2}^{\times}$, and prove that the isomorphism identifies SPB-DH triples precisely with standard Computational Diffie-Hellman triples in that finite-field subgroup. This is the missing cryptographic bridge that lets us carry classical finite-field hardness assumptions into the SPB tropical-algebraic setting.

**Target Theorems.** Formalize the following in Lean 4:

```lean
import Mathlib
open Polynomial

variable (p : ℕ) [Fact p.Prime]

/-- The SPB phase group: points on x² + y² = 1 over 𝔽_p. -/
structure SPBCircle (p : ℕ) where
  x : ZMod p
  y : ZMod p
  eq : x^2 + y^2 = 1

noncomputable instance : Group (SPBCircle p) where
  mul P Q := ⟨P.x * Q.x - P.y * Q.y, P.x * Q.y + P.y * Q.x,
    by rw [←pow_two] at *; ring_nf at *; simp [P.eq, Q.eq]; ring⟩
  one := ⟨1, 0, by simp⟩
  inv P := ⟨P.x, -P.y, by rw [neg_sq, P.eq]⟩
  mul_assoc := by intros; apply SPBCircle.ext; simp [mul_add, add_mul, sub_eq_add_neg]; ring
  one_mul := by intros; apply SPBCircle.ext; simp
  mul_one := by intros; apply SPBCircle.ext; simp
  mul_left_inv := by intros; apply SPBCircle.ext; simp; rw [P.eq]; ring

/-- The quadratic extension 𝔽_{p²} = 𝔽_p(i) where i² = -1, valid when p ≡ 3 (mod 4). -/
def SPBField (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) : Type _ :=
  AdjoinRoot (X^2 + 1 : (ZMod p)[X])

theorem irreducible_X_sq_add_one_of_p_eq_three_mod_four {p : ℕ} [Fact p.Prime]
    (hp : p % 4 = 3) : Irreducible (X^2 + 1 : (ZMod p)[X]) := by sorry

noncomputable instance instFieldSPB (hp : p % 4 = 3) : Field (SPBField p hp) := by
  letI := AdjoinRoot.instFieldOfIrreducible (X^2 + 1)
    (irreducible_X_sq_add_one_of_p_eq_three_mod_four hp)
  infer_instance

/-- Main security theorem: the SPB circle group is isomorphic to the order-(p+1) roots of
    unity in the multiplicative group of 𝔽_{p²}. This gives the explicit transfer
    map needed for the reduction. -/
theorem SPB_DH_Security_Reduction (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) :
    Nonempty (SPBCircle p ≃* rootsOfUnity (p + 1) (Multiplicative (SPBField p hp))) := by sorry

/-- Corollary: the SPB-DH relation and the standard finite-field CDH relation are
    identically equivalent via the isomorphism. An adversary breaking one immediately
    breaks the other with the same exponents. -/
theorem spb_dh_cdh_equivalence (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3)
    (φ : SPBCircle p ≃* rootsOfUnity (p + 1) (Multiplicative (SPBField p hp)))
    (P aP bQ S : SPBCircle p) :
    (∃ a b : ℕ, aP = P ^ a ∧ bQ = P ^ b ∧ S = P ^ (a * b)) ↔
    (∃ a b : ℕ,
      (φ aP : Multiplicative (SPBField p hp)).val = (φ P).val ^ a ∧
      (φ bQ : Multiplicative (SPBField p hp)).val = (φ P).val ^ b ∧
      (φ S  : Multiplicative (SPBField p hp)).val = (φ P).val ^ (a * b)) := by sorry
```

**Proof Strategy.** Build on the algebraic infrastructure already available in the catalog: the SPB deformation theorems (associativity, cancellation, and the Pythagorean-triple connection — 9 verified theorems), the group-law reversal machinery in `group_reversal_identity`, and the quadratic-form-to-multiplicative-group spirit of the Lorentz-form reduction in `BerggrenFactoring.lean`. The proof should proceed in three concrete steps:

1. **Construct the quadratic extension and verify its cardinality.** Prove that `X^2 + 1` is irreducible over `ZMod p` whenever `p % 4 = 3`. Use `ZMod.exists_sq_eq_neg_one_iff` (Euler-criterion consequence) to show `-1` is a non-residue, then apply `Polynomial.irreducible_of_degree_two` (or `irreducible_of_degree_eq_two_of_not_isRoot`) to obtain the irreducibility certificate. This gives a field structure on `AdjoinRoot (X^2 + 1)`. Record that its vector-space dimension over `ZMod p` equals 2 via `AdjoinRoot.powerBasis`, whence `Fintype.card (SPBField p hp) = p^2` (apply `Module.card_fintype` together with `Fintype.card_zmod`). Consequently the unit group has cardinality `p^2 - 1`.

2. **Define the explicit homomorphism `φ(x,y) = x + y·i` and show its image lies in the norm-1 subgroup.** Let `i := AdjoinRoot.root (X^2 + 1)`. Define `φ` as a map into the unit group of the extension; prove it is a homomorphism by expanding `(x₁ + y₁·i)(x₂ + y₂·i)` using `RingHom.map_mul`, `RingHom.map_add`, and the defining relation `i^2 = -1` (invoke `AdjoinRoot.eval₂_root`). Prove invertibility via `Units.mk0` with explicit inverse `x - y·i`, noting that `(x+yi)(x-yi) = x^2 + y^2 = 1` inside the ring. Establish the norm identity with `mul_add` and direct computation; then apply `Field.norm_eq_pow` (or `FiniteField.norm_to_zmod_eq_pow`) for the quadratic extension to obtain `(φ P)^(p+1) = 1`. Use `rootsOfUnity.mk_of_pow_eq_one` to witness that the image sits inside `rootsOfUnity (p+1)`.

3. **Close bijectivity by counting.** Prove injectivity of `φ` from the linear independence of the power basis (`PowerBasis.basis`): if `x₁ + y₁·i = x₂ + y₂·i` then `x₁ = x₂` and `y₁ = y₂`. Count the source by exhibiting an `Equiv` between `SPBCircle p` and `Option (ZMod p)` via the stereographic parametrization `t ↦ ((1-t²)/(1+t²), 2t/(1+t²))` together with the point `(-1,0)`; since `1 + t² ≠ 0` (as `-1` is a non-residue), this is well-defined everywhere, and `Fintype.card_option` gives `|SPBCircle p| = p + 1`. For the target, the norm map `N : Fˣ → (ZMod p)ˣ` is surjective (`FiniteField.norm_surjective`), so the first isomorphism theorem (`Subgroup.index_ker` combined with `Fintype.card_eq_card_quotient_mul_card_subgroup`) yields that its kernel — our target subgroup — has cardinality `(p² - 1)/(p - 1) = p + 1`. Because `φ` is an injective homomorphism between finite groups of identical cardinality, conclude it is bijective via `Function.bijective_iff_injective_and_surjective`.

**Why this result matters.** This theorem completes the machine-verified security reduction for the SPB Diffie-Hellman protocol. It proves that breaking SPB-DH is polynomial-time equivalent to solving the standard Computational Diffie-Hellman problem in the unique order-$(p+1)$ subgroup of $\mathbb{F}_{p^2}^{\times}$: the explicit isomorphism $\varphi$ and its computable inverse translate adversarial success identically between the two settings. The result anchors the SPB tropical-algebraic cryptography program (built on the catalog's existing SPB deformation theorems) onto classical finite-field hardness assumptions, and it is a direct prerequisite for the CRYSTALS-Dilithium security-reduction pipeline and the broader classical-quantum-tropical correspondence for public-key exchange.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Cryptography
Research mode: prove
