# Research Notes — Foundations of the Algebraic Theory of Magnetism

## Session 1: Defining the Magnetic Algebra

### 1.1 The Single-Spin Algebra

**Definition (Spin Algebra).** The fundamental magnetic algebra is the Lie algebra
𝔰𝔲(2) with generators {S₊, S₋, Sᵤ} satisfying:

    [Sᵤ, S₊] = +S₊
    [Sᵤ, S₋] = -S₋
    [S₊, S₋] = 2Sᵤ

Equivalently, in Cartesian form {Sₓ, Sᵧ, Sᵤ}:

    [Sₓ, Sᵧ] = iSᵤ   (and cyclic permutations)

The Casimir element C = Sₓ² + Sᵧ² + Sᵤ² commutes with all generators.

**Representations:** Irreducible representations are labeled by spin quantum
number s ∈ {0, ½, 1, 3/2, ...}, with dimension 2s+1. The Casimir takes value
s(s+1) in representation Vₛ.

**Physical interpretation:** Each magnetic ion carries a representation Vₛ. The
most common cases:
- s = ½: Electrons, spin-½ ions (Cu²⁺, Ce³⁺)
- s = 1: Spin-1 ions (Ni²⁺), Haldane chains
- s = 5/2: Fe³⁺, Mn²⁺ (high-spin d⁵)

### 1.2 The Many-Body Magnetic Algebra

**Definition (Lattice Magnetic Algebra).** For a lattice Λ with N sites, the
many-body magnetic algebra is:

    𝔐_Λ = ⊗ᵢ∈Λ 𝔰𝔲(2)ᵢ

This is the tensor product of N copies of 𝔰𝔲(2), embedded in End(⊗ᵢ Vₛᵢ).

**Structure:** The algebra 𝔐_Λ carries:
1. A **Lie algebra structure** from the component 𝔰𝔲(2)'s
2. An **associative algebra structure** from the matrix embedding
3. A **coalgebra structure** from the tensor product (Hopf algebra)
4. A **lattice symmetry action** from Aut(Λ)

### 1.3 The Universal Magnetic Hamiltonian

**Theorem (Universality).** Every bilinear spin Hamiltonian on Λ has the form:

    H = Σᵢⱼ Σ_αβ Jᵢⱼᵅᵝ Sᵢᵅ Sⱼᵝ + Σᵢ Σ_α hᵢᵅ Sᵢᵅ

where α,β ∈ {x,y,z}, Jᵢⱼ is the exchange tensor, and hᵢ is the local field.

**Proof sketch:** The most general element of 𝔐_Λ quadratic in generators,
compatible with hermiticity, has exactly this form. ∎

**Key observation:** The exchange tensor Jᵢⱼᵅᵝ is an element of:

    J ∈ ℝ^(|Λ|×|Λ|) ⊗ ℝ^(3×3)

This decomposes under O(3) as:

    J = J_iso · I₃ + J_DM · ε + J_sym

where:
- J_iso: Isotropic (Heisenberg) exchange — scalar part
- J_DM: Dzyaloshinskii-Moriya exchange — antisymmetric part  
- J_sym: Symmetric anisotropic exchange — traceless symmetric part

### 1.4 Classification of Magnetic Models by Algebraic Reduction

| Model      | Symmetry Algebra | Exchange Tensor    | Order Parameter Space |
|------------|-----------------|--------------------|-----------------------|
| Ising      | ℤ₂ (abelian)    | Jᵤᵤ only          | S⁰ = {±1}           |
| XY         | U(1) ≅ SO(2)    | Jₓₓ = Jᵧᵧ         | S¹                   |
| Heisenberg | SU(2) ≅ SO(3)   | Jₓₓ = Jᵧᵧ = Jᵤᵤ   | S²                   |
| Kitaev     | ℤ₂ × ℤ₂ × ℤ₂   | Bond-dependent     | ℤ₂ gauge field       |
| DM         | Broken SO(3)    | + antisymmetric    | S² (canted)          |
| Compass    | Discrete        | Direction-dependent | Discrete set          |

**Oracle Emmy's observation:** This table IS the classification theorem. Each
model corresponds to a choice of subalgebra of 𝔐_Λ, and the order parameter
space is the coset G/H where G is the full symmetry and H is the residual
symmetry in the ordered phase.

### 1.5 The Magnetic Representation Ring

**Definition.** The magnetic representation ring R(𝔰𝔲(2)) is the Grothendieck
ring of finite-dimensional representations. It is isomorphic to ℤ[χ], the
polynomial ring in one variable (the character of the fundamental representation).

**Multiplication rule (Clebsch-Gordan):**

    Vₛ₁ ⊗ Vₛ₂ = V_{|s₁-s₂|} ⊕ V_{|s₁-s₂|+1} ⊕ ... ⊕ V_{s₁+s₂}

**Physical meaning:** When two magnetic ions interact, the Hilbert space of the
pair decomposes into irreducible sectors. The ground state "chooses" one sector,
defining the magnetic order:
- Ferromagnetic: ground state in V_{s₁+s₂} (maximal spin)
- Antiferromagnetic: ground state in V_{|s₁-s₂|} (minimal spin)

---

## Session 2: Algebraic Order Parameters

### 2.1 Symmetry Breaking as Algebra Homomorphism

**Definition (Algebraic Order Parameter).** An algebraic order parameter for a
magnetic phase is a non-trivial algebra homomorphism:

    φ: 𝔐_Λ → 𝔄_order

where 𝔄_order is the order parameter algebra, characterizing the broken symmetry.

**Examples:**
- Ferromagnet: φ maps total spin S_total to a classical vector m ∈ ℝ³
- Antiferromagnet: φ maps staggered spin N = Σ(-1)ⁱSᵢ to n ∈ ℝ³  
- Spin liquid: φ is trivial (no local order parameter) — the order is
  topological, living in the center of a gauge algebra

### 2.2 The Algebraic Phase Diagram

**Theorem (Phase Classification).** For a magnetic system with Hamiltonian
H ∈ 𝔐_Λ, the zero-temperature phases are classified by:

1. The **stabilizer subalgebra** 𝔥 ⊂ 𝔐_Λ of the ground state
2. The **coset space** G/H of the symmetry breaking
3. The **topological invariants** πₙ(G/H) of the order parameter space

**Iteration note:** This theorem unifies Landau theory (symmetry breaking),
topological classification (homotopy), and algebraic structure in a single
framework. This is the core claim of our theory.

---

## Session 3: Algebraic Dynamics

### 3.1 The Landau-Lifshitz Equation as Algebra Flow

The Landau-Lifshitz equation for magnetization dynamics:

    ∂M/∂t = -γ M × H_eff

is equivalently the adjoint action flow on 𝔰𝔲(2)*:

    ∂M/∂t = ad*_{δH/δM}(M)

This is a **Hamiltonian flow on the coadjoint orbit** O_s ≅ S² of 𝔰𝔲(2)*.

**Oracle Élie's observation:** The coadjoint orbit S² is a symplectic manifold
with the Kirillov-Kostant-Souriau form:

    ω = s · sin θ dθ ∧ dφ

(proportional to the area form on S²). The Landau-Lifshitz equation is Hamilton's
equation with respect to this symplectic structure.

### 3.2 Magnon Algebra

**Definition (Magnon Algebra).** For a ferromagnetic ground state, the magnon
algebra is the Weyl algebra W₁ (bosonic creation/annihilation operators)
obtained via the Holstein-Primakoff transformation:

    S₊ ≈ √(2s) a      (for low excitations)
    S₋ ≈ √(2s) a†
    Sᵤ = s - a†a

This maps the 𝔰𝔲(2) algebra to the Heisenberg-Weyl algebra:

    [a, a†] = 1

**Physical meaning:** Magnons (spin waves) are the bosonic quasiparticles of
the magnetically ordered phase. Their algebra emerges as a contraction of
𝔰𝔲(2) in the large-s limit.

---

## Key Hypotheses (For Experimental Validation)

**H1:** All magnetic phase transitions can be classified by changes in the
stabilizer subalgebra of the ground state.

**H2:** Topological magnetic textures (skyrmions, merons, hedgehogs) are
classified by πₙ(G/H), computable from the algebraic data alone.

**H3:** Selection rules for magnetic spectroscopy follow from the
Clebsch-Gordan decomposition of the probe operator in the magnetic algebra.

**H4:** Novel magnetic phases can be systematically constructed by choosing
exotic subalgebras of the universal magnetic algebra.

---

## Experimental Validation Checklist

- [x] Curie-Weiss mean field → recovered from algebraic mean field (Session 4)
- [x] Mermin-Wagner theorem → follows from representation theory of continuous
      symmetries in d ≤ 2 (Session 5)
- [x] Magnon dispersion → Holstein-Primakoff is an algebra homomorphism (Session 3)
- [x] Skyrmion classification → π₂(S²) = ℤ from algebraic topology (Session 6)
- [x] Ising exact solution → ℤ₂ transfer matrix algebra (Session 7)
