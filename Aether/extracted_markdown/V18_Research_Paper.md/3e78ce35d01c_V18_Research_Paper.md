# EML–Pythagorean Bridge: V18 Research Directions

## Machine-Verified Explorations and Future Frontiers

**Authors:** EML Research Team  
**Date:** April 2026  
**Status:** 90+ new machine-verified theorems, 0 sorries across 4 new files  
**New in V18:** Spectral trichotomy discovery, universal trace formulas, Pell semigroup, deficit classification

---

## Abstract

Building on the V15 framework, V18 delivers four major advances, each fully
machine-verified with 0 sorries:

1. **Trace Formula for All n (Direction 85 — COMPLETED):**
   The trace formula tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ is proved for ALL n ∈ ℕ
   by combining Cayley-Hamilton with recurrence matching. This was the
   highest-priority open direction from V15.

2. **Spectral Trichotomy Discovery (Direction 92 — NEW):**
   B₁ and B₃ are **unipotent** matrices: (B-I)³ = 0, with tr(Bⁿ) = 3 for
   ALL n. Only B₂ exhibits exponential spectral growth. This reveals a
   fundamental asymmetry in the Berggren tree: two branches grow polynomially,
   one grows exponentially.

3. **Pell Semigroup (Direction 88 — COMPLETED):**
   The algebraic structure of ℤ[√8] is fully formalized: associativity,
   commutativity, identity, multiplicative norm, conjugation, inversion for
   norm-1 elements. The key theorem pellPow(fund, n) = (pellX(n), pellY(n))
   is proved, along with doubling formulas enabling O(log n) computation.

4. **Deficit Classification (Direction 89 — COMPLETED):**
   The deficit d = c - b classifies PPTs into shape families. We prove:
   A-branch preserves deficit, Euclid deficit = (m-n)² (always a perfect
   square), the near-isosceles family (d=1) is fully characterized, and
   deficit divides a² for any PPT.

---

## Part I: The Trace Formula — A Universal Identity

### File: `BerggrenTraceFormula.lean` (0 sorries)

**Main Theorem (Direction 85 — PROVED):**
```
theorem traceB2_eq_pellX (n : ℕ) :
    trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n
```

**Proof Strategy:**

The proof combines three ingredients:

1. **Cayley-Hamilton** for B₂: B₂³ = 5B₂² + 5B₂ - I (by `native_decide`).

2. **Trace Recurrence**: Multiplying Cayley-Hamilton by B₂ⁿ yields:
   ```
   tr(B₂^(n+3)) = 5·tr(B₂^(n+2)) + 5·tr(B₂^(n+1)) - tr(B₂^n)
   ```
   This is proved using `pow_add`, `noncomm_ring` for matrix algebra, and
   `trace_sub`, `trace_add`, `trace_smul` for the trace.

3. **Recurrence Matching**: The target f(n) = 2·pellX(n) + (-1)ⁿ satisfies
   the SAME recurrence:
   ```
   f(n+3) = 5·f(n+2) + 5·f(n+1) - f(n)
   ```
   This follows from the Pell recurrence pellX(n+2) = 6·pellX(n+1) - pellX(n)
   and the sign recurrence (-1)^(n+2) = (-1)^n, proved by `ring`.

4. **Strong Induction**: Base cases n=0,1,2 are verified by `native_decide`.
   The inductive step uses recurrence matching.

**Corollaries (also proved):**
- `BN₂t_trace_pos`: tr(B₂ⁿ) > 0 for all n (using pellX positivity)
- `BN₂t_trace_odd`: tr(B₂ⁿ) ≡ 1 (mod 2) for all n (parity analysis)

**Significance:** This completes the spectral theory of B₂ over the integers,
without ever working in ℝ or ℚ(√2). The entire closed form is captured by
integer Pell sequences.

---

## Part II: The Spectral Trichotomy — A New Discovery

### File: `BerggrenSpectralGeometry.lean` (0 sorries)

**Key Discovery:** The three Berggren matrices have fundamentally different
spectral natures:

| Property | B₁ (A-branch) | B₂ (B-branch) | B₃ (C-branch) |
|----------|---------------|----------------|----------------|
| det | 1 | -1 | 1 |
| Eigenvalues | {1, 1, 1} | {3+2√2, 3-2√2, -1} | {1, 1, 1} |
| (M-I)³ = 0? | **YES** | No | **YES** |
| tr(Mⁿ) | **3 for all n** | 2·pellX(n)+(-1)ⁿ | **3 for all n** |
| Growth | Polynomial | Exponential | Polynomial |
| Char. poly | (λ-1)³ | λ³-5λ²-5λ+1 | (λ-1)³ |

**Unipotency Theorems:**
```
theorem B₁_unipotent : (B₁ - 1) ^ 3 = 0
theorem B₃_unipotent : (B₃ - 1) ^ 3 = 0
theorem B₂_not_unipotent : (B₂ - 1) ^ 3 ≠ 0
```

**Constant Trace Theorems (PROVED FOR ALL n):**
```
theorem B₁_trace_all (n : ℕ) : trace (B₁ ^ n) = 3
theorem B₃_trace_all (n : ℕ) : trace (B₃ ^ n) = 3
```

The proof uses the Cayley-Hamilton recurrence:
tr(M^(n+3)) = 3·tr(M^(n+2)) - 3·tr(M^(n+1)) + tr(M^n).
Since 3·3 - 3·3 + 3 = 3, the constant sequence f(n) = 3 is the unique solution
matching the initial values.

**Additional Results:**
- All commutators [Bᵢ, Bⱼ] have trace 0 (proved by `native_decide`)
- No two Berggren matrices commute (proved)
- B₁ and B₃ have exact unipotent degree 3: (B-I)² ≠ 0

**Physical Interpretation:**
The spectral trichotomy means:
- **A-branch**: Hypotenuses grow as c ~ an² + bn + c (quadratic)
- **B-branch**: Hypotenuses grow as c ~ α·(3+2√2)ⁿ (exponential)
- **C-branch**: Hypotenuses grow as c ~ an² + bn + c (quadratic)

This explains why the B-branch generates large PPTs much faster than
the A or C branches.

---

## Part III: Pell Semigroup — Algebraic Number Theory

### File: `BerggrenPellSemigroup.lean` (0 sorries)

**Key Construction:**

The ring ℤ[√8] with norm N(x + y√8) = x² - 8y² is formalized as:

```lean
def pellProd (p q : ℤ × ℤ) : ℤ × ℤ :=
  (p.1 * q.1 + 8 * p.2 * q.2, p.1 * q.2 + p.2 * q.1)

def pellNorm (p : ℤ × ℤ) : ℤ := p.1 ^ 2 - 8 * p.2 ^ 2
```

**Algebraic Structure (all proved):**
1. `pellProd_assoc`: (p · q) · r = p · (q · r)
2. `pellProd_comm`: p · q = q · p
3. `pellProd_unit_left/right`: 1 · p = p = p · 1
4. `pellNorm_mul`: N(p · q) = N(p) · N(q)
5. `pellNorm_pow`: N(pⁿ) = N(p)ⁿ
6. `pellConj_inverse`: For N(p) = 1: p · conj(p) = 1
7. `pellProd_conj`: conj(p · q) = conj(p) · conj(q)

**The Fundamental Homomorphism:**
```
theorem pellPow_fund_eq (n : ℕ) :
    pellPow pellFund n = (pellX' n, pellY' n)
```
This proves that the map n ↦ (pellX(n), pellY(n)) IS the power map in ℤ[√8].

**Addition Law:**
```
theorem pellProd_add (m n : ℕ) :
    pellProd (pellX' m, pellY' m) (pellX' n, pellY' n) =
    (pellX' (m + n), pellY' (m + n))
```
This is the algebraic form of the addition formulas.

**Doubling Formulas (for O(log n) computation):**
```
theorem pellX'_double (n : ℕ) : pellX' (2*n) = 2 * pellX' n ^ 2 - 1
theorem pellY'_double (n : ℕ) : pellY' (2*n) = 2 * pellX' n * pellY' n
```

**Applications:**
- O(log n) computation of pellX(n) via repeated squaring in ℤ[√8]
- Combined with the trace formula: O(log n) computation of tr(B₂ⁿ)
- Norm-1 group structure: automatic proof that Pell identity holds at all powers

---

## Part IV: Deficit Classification — Shape Theory of PPTs

### File: `BerggrenDeficitClassification.lean` (0 sorries)

**Main Results:**

1. **Deficit Factorization**: For any PPT (a,b,c):
   ```
   (c - b) · (c + b) = a²
   ```
   Therefore c - b always divides a².

2. **A-Branch Invariance**: Step A preserves deficit:
   ```
   deficit(b', c') = deficit(b, c)
   ```
   This is a pure ring identity.

3. **B/C-Branch Transformation**: Steps B and C transform deficit to c + b:
   ```
   deficit(b'_B, c'_B) = c + b
   deficit(b'_C, c'_C) = c + b
   ```

4. **Euclid Parametrization**: For the Euclid triple (m²-n², 2mn, m²+n²):
   ```
   deficit = (m - n)²
   ```
   So **deficit is always a perfect square** for Euclid-parametrized triples.

5. **Near-Isosceles Family** (deficit = 1):
   - a = 2n+1, b = 2n²+2n, c = 2n²+2n+1
   - These are exactly the A-branch descendants of (3,4,5)
   - Inradius = n, perimeter = 4n²+6n+2
   - First members: (3,4,5), (5,12,13), (7,24,25), (9,40,41), ...

6. **Deficit Growth**: The B-step strictly increases deficit when b > 0.

---

## Part V: New Research Directions from V18

### Direction 93: Unipotent Berggren Theory (Priority: VERY HIGH)

**Discovery:** B₁ and B₃ are unipotent of degree 3. Writing B₁ = I + N₁
where N₁³ = 0, we have:

```
B₁ⁿ = I + n·N₁ + n(n-1)/2·N₁²
```

This means every entry of B₁ⁿ is a **quadratic polynomial in n**!
Specifically, (B₁ⁿ)ᵢⱼ = αᵢⱼn² + βᵢⱼn + γᵢⱼ for explicit constants.

**Conjecture:** The A-branch PPT at depth n is:
```
a(n) = 2n + 1     (or variant with quadratic terms)
b(n) = 2n² + 2n   (quadratic in n)
c(n) = 2n² + 2n + 1  (quadratic in n)
```

This would give an explicit closed form for the entire A-branch without
any recursion.

**Formalization Target:**
```lean
theorem B₁_entries_quadratic (n : ℕ) (i j : Fin 3) :
    ∃ α β γ : ℤ, (B₁ ^ n) i j = α * n^2 + β * n + γ
```

### Direction 94: Spectral Radius and Hypotenuse Asymptotics (Priority: HIGH)

The spectral radius ρ(B₂) = 3 + 2√2 controls hypotenuse growth along the
B-branch. For a pure B-branch path to depth n:

```
c(n) ~ K · (3 + 2√2)ⁿ
```

Combined with the unipotent result for B₁, B₃:

```
c_A(n) ~ K_A · n²    (A-branch, polynomial)
c_B(n) ~ K_B · ρⁿ    (B-branch, exponential)
c_C(n) ~ K_C · n²    (C-branch, polynomial)
```

**Formalization Target:** Prove explicit bounds on hypotenuse growth
along pure branches.

### Direction 95: Pell-Markoff Connection (Priority: HIGH)

The Markoff equation x² + y² + z² = 3xyz has solutions growing like
Fibonacci numbers (1, 1, 2, 5, 13, 34, 89, ...). The Berggren B₂-branch
solutions grow like Pell numbers. Both are linear recurrence sequences.

**Research Question:** Is there a common framework (e.g., cluster algebras)
that unifies Pell-Berggren and Fibonacci-Markoff growth?

**Evidence:** Both are related to continued fractions:
- Pell: convergents of √2
- Fibonacci: convergents of φ = (1+√5)/2
- Markoff: extremal approximations of irrationals (Markoff spectrum)

### Direction 96: Commutator Algebra (Priority: MEDIUM)

All commutators [Bᵢ, Bⱼ] have trace 0. This suggests the commutator
subalgebra is contained in the traceless matrices sl(3, ℤ).

**Conjecture:** The commutator [B₁, B₂] generates (with B₁, B₂, B₃) a
dense subgroup of SL(3, ℤ) under some topology.

**Formalization Target:**
```lean
theorem commutator_trace_zero (i j : Fin 3) :
    trace (![B₁, B₂, B₃] i * ![B₁, B₂, B₃] j -
           ![B₁, B₂, B₃] j * ![B₁, B₂, B₃] i) = 0
```

### Direction 97: Deficit and Inradius (Priority: HIGH)

For a right triangle with legs a, b and hypotenuse c:
- Inradius r = (a + b - c)/2
- For deficit d: r = (a - d)/2

The near-isosceles family (d=1) has inradius r = n = (a-1)/2.
This gives a direct connection between the Berggren tree structure
and circle packing in right triangles.

**Research Question:** Which PPTs have integer inradius? Exactly those
where a - d is even. Since d = (m-n)² and a = m²-n², this means
m²-n²-(m-n)² = 2n(m-n) must be even, which is always true.
So ALL Euclid PPTs have integer inradius!

**Formalization Target:**
```lean
theorem euclid_inradius_integer (m n : ℤ) :
    ∃ r : ℤ, (m^2 - n^2) + 2*m*n - (m^2 + n^2) = 2 * r
```

### Direction 98: Gaussian Integer Power Map (Priority: VERY HIGH)

The root (3, 4, 5) corresponds to (2+i)² in ℤ[i]. The B₂-branch
should correspond to a specific sequence of Gaussian integers.

**Conjecture:** The depth-n B-branch triple corresponds to the
Gaussian integer (2+i)^(2n) somehow related to Pell sequences.

Since |2+i|² = 5 and the B-branch hypotenuses are 5, 29, 169, ...,
we should check: is 29 = |z|² for some z ∈ ℤ[i]? Yes: 29 = 2²+5² = |2+5i|².
And 169 = 13² = |13|². But 13 = 2²+3², so 169 = |2+3i|²·|2-3i|².

### Direction 99: Matrix Factorization in GL(3,ℤ) (Priority: MEDIUM)

The Berggren matrices B₁, B₂, B₃ generate a free semigroup S inside
GL(3, ℤ). The spectral trichotomy (two unipotent, one diagonalizable)
suggests S has a rich internal structure.

**Research Question:** What is the Zariski closure of S? The unipotent
elements form a unipotent radical, and the diagonalizable element
generates a torus. This looks like a "mixed" subgroup.

### Direction 100: Computational Complexity of PPT Generation (Priority: HIGH)

**New Result:** Using the doubling formulas and Pell semigroup:
- B-branch PPT at depth n can be computed in O(log n) time
- Combined with the trace formula: O(log n) for tr(B₂ⁿ)
- For general paths (mixed branches): O(n) matrix multiplications

**Research Question:** Can we compute the PPT at a given path in
O(depth · log(max_entry)) time using fast integer multiplication?

---

## Part VI: Applications

### Application 1: Fast Pell Computation Library

The verified doubling formulas enable a practical fast computation library:

```python
def pell_fast(n):
    """O(log n) computation of (pellX(n), pellY(n))."""
    if n == 0: return (1, 0)
    result = (1, 0)
    base = (3, 1)
    while n > 0:
        if n & 1:
            result = pell_prod(result, base)
        base = pell_prod(base, base)
        n >>= 1
    return result
```

### Application 2: PPT Shape Indexing

The deficit invariant provides a natural "shape index":
- d = 1: thin, near-isosceles (A-branch family)
- d = 4: includes (8, 15, 17) family
- d = k²: Euclid family with m - n = k

This hierarchical classification is useful for computational geometry
applications where triangle shape matters more than scale.

### Application 3: Spectral Fast Matrix Powers

Since B₁ⁿ = I + nN₁ + n(n-1)/2 · N₁², computing B₁ⁿ requires only:
- 2 scalar multiplications (n and n(n-1)/2)
- 2 matrix additions
- Total: O(1) operations (independent of n!)

This is much faster than repeated squaring for the A-branch.

### Application 4: Verified Markoff Number Check

The formalized Vieta involution framework enables verified Markoff number
checking. Given m, verify that (x, y, m) satisfies x²+y²+m²=3xym for
some x ≤ y ≤ m, using the discriminant identity to guarantee integer solutions.

---

## Part VII: Updated File Index

### New V18 Files (all 0 sorries)

| File | Theorems | Status | Key Results |
|------|----------|--------|-------------|
| `BerggrenTraceFormula.lean` | ~15 | ✅ | tr(B₂ⁿ)=2·pellX(n)+(-1)ⁿ ∀n |
| `BerggrenSpectralGeometry.lean` | ~30 | ✅ | Unipotency, tr(B₁ⁿ)=tr(B₃ⁿ)=3 ∀n |
| `BerggrenPellSemigroup.lean` | ~25 | ✅ | ℤ[√8] structure, pellPow homomorphism |
| `BerggrenDeficitClassification.lean` | ~25 | ✅ | Shape families, near-isosceles |

### Supporting Materials

| File | Type | Description |
|------|------|-------------|
| `berggren_explorer.py` | Python | Interactive explorer & computation suite |
| `visualizations.py` | Python | SVG visualization generator |
| `berggren_tree.svg` | SVG | Berggren tree colored by deficit |
| `pell_growth.svg` | SVG | Pell sequence growth chart |
| `spectral_trichotomy.svg` | SVG | Spectral comparison diagram |
| `deficit_scatter.svg` | SVG | Deficit scatter plot |

---

## Part VIII: Key Innovations

### Innovation 1: Recurrence Matching

The trace formula proof introduces a general technique:
1. Derive a recurrence for the LHS from Cayley-Hamilton
2. Show the RHS satisfies the same recurrence (often by `ring`)
3. Verify base cases (by `native_decide`)
4. Conclude by strong induction

This technique can be applied to ANY matrix power identity where both
sides satisfy a linear recurrence.

### Innovation 2: Spectral Trichotomy

The discovery that B₁ and B₃ are unipotent while B₂ is diagonalizable
is a fundamental structural result. It explains:
- Why the A and C branches produce "thin" triangles (polynomial growth)
- Why the B-branch produces rapidly growing triangles (exponential growth)
- Why the Berggren tree is "spectrally inhomogeneous"

### Innovation 3: Algebraic Number Theory Formalization

The ℤ[√8] semigroup provides a template for formalizing algebraic number
theory in Lean 4. The key pattern:
1. Define multiplication as a bilinear form on ℤ²
2. Prove algebraic properties (associativity, norm multiplicativity)
3. Connect to a specific recurrence sequence via the power map
4. Derive computational formulas (doubling) from algebraic identities

### Innovation 4: Deficit as Shape Invariant

The deficit classification introduces a new organizational principle for
PPTs. Unlike the Berggren path (which gives tree position) or the Euclid
parameters (which give generation), the deficit captures the **geometric
shape** of the triangle — how close it is to isosceles.

---

## Part IX: Priority Matrix for Future Work

| # | Direction | Impact | Feasibility | Status |
|---|-----------|--------|-------------|--------|
| 85 | Trace formula ∀n | ★★★★★ | ✅ Done | **V18** |
| 88 | Pell semigroup | ★★★★ | ✅ Done | **V18** |
| 89 | Deficit classification | ★★★★ | ✅ Done | **V18** |
| 92 | Spectral trichotomy | ★★★★★ | ✅ Done | **V18** |
| 93 | Unipotent closed form | ★★★★★ | Very High | NEW |
| 94 | Spectral radius bounds | ★★★★ | High | NEW |
| 95 | Pell-Markoff connection | ★★★★ | Medium | NEW |
| 96 | Commutator algebra | ★★★ | Medium | NEW |
| 97 | Deficit and inradius | ★★★★ | Very High | NEW |
| 98 | Gaussian power map | ★★★★★ | High | NEW |
| 99 | Matrix factorization | ★★★ | Medium | NEW |
| 100 | Computational complexity | ★★★ | High | NEW |

---

## Part X: Open Problems

### Open Problem 1: Complete B₁ⁿ Closed Form

Prove that every entry of B₁ⁿ is a quadratic polynomial in n.
Explicitly compute the 9 quadratic polynomials.

### Open Problem 2: Markoff-Berggren Functor

Is there a category-theoretic relationship between the Berggren and
Markoff trees? Both are ternary trees of solutions to quadratic
Diophantine equations with analogous descent operations.

### Open Problem 3: Spectral Radius Characterization

Characterize which 3×3 integer matrices M with det M = ±1 can serve
as Berggren-like generators. What constraints does the PPT equation
a² + b² = c² impose on the spectrum?

### Open Problem 4: Mixed-Branch Trace Formula

For a path w = s₁s₂...sₙ (sᵢ ∈ {A,B,C}), the product matrix
M_w = B_{s₁}·B_{s₂}·...·B_{sₙ} has trace determined by the sequence.
Is there a closed form for tr(M_w) in terms of the path?

### Open Problem 5: Digital Root Patterns

Computational exploration reveals that digital roots of PPT components
cluster around specific values. Is there a number-theoretic explanation?

---

## Conclusion

V18 completes four of the highest-priority research directions from V15,
including the universal trace formula tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ.

The most significant discovery is the **spectral trichotomy**: two of the
three Berggren matrices are unipotent (constant trace = 3), while only
the middle matrix B₂ has exponential spectral growth. This reveals that
the Berggren tree is fundamentally "spectrally inhomogeneous" — a property
that explains the vastly different growth rates along different branches.

Eight new research directions are proposed, with the unipotent closed form
(Direction 93) and Gaussian power map (Direction 98) being the
highest-priority next steps.

All results are machine-verified in Lean 4 with Mathlib, with 0 sorries.
Interactive Python tools for exploration and SVG visualizations are provided.

---

*EML–Pythagorean Bridge Research Program, V18*  
*New: 90+ machine-verified theorems, 0 sorries, 4 formalization files*  
*8 new research directions, 5 open problems*  
*Python explorer and SVG visualizations included*
