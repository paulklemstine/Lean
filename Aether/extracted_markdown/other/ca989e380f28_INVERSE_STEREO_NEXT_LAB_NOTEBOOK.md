# 🔬 Inverse Stereographic Möbius: What's Next — Lab Notebook
## Extending Machine-Verified Results on Integer-to-Integer Mappings

### Mission
Building on the 30+ verified theorems in `InverseStereoMobius.lean`, explore the open
questions from "The Map That Maps Numbers to Numbers": the complete criterion, finiteness,
matrix representations, orbit theory, and connections to cryptography.

### Results Summary
- **30+ NEW theorems** in `InverseStereoMobiusNext.lean`, **all machine-verified** (zero sorry)
- **8 deep theorems** proved by the theorem proving subagent, covering all major open directions
- **Total: 60+ verified theorems** across both files

---

## 🧪 Experiments & Results

### Experiment 1: The Complete Criterion

**Hypothesis**: The necessary condition (denominator divides determinant) and the
sufficient condition can be made precise.

**Results**:
- ✅ `complete_criterion_forward`: If den | num, then den | det
- ✅ `complete_criterion_backward`: If den | det, then den | (b-a)·num
- ✅ `den_num_linear_relation`: The Bézout-like identity linking den, num, and det

**Key Insight**: The complete criterion is: F_{a,b}(n) ∈ ℤ ⟺ (a-b)n + (ab+1) divides
(ab+1)n + (b-a). The necessary direction gives den | det = (1+a²)(1+b²). The backward
direction shows this is "almost sufficient" — den | det implies den | (b-a)·num, so
it suffices to additionally have gcd(den, b-a) | num.

### Experiment 2: Finiteness of Integer-Mapping Set

**Hypothesis**: Only finitely many integers map to integers under F_{a,b} when a ≠ b.

**Results**:
- ✅ `divisor_bound`: |den(n)| ≤ |det| when den | det
- ✅ `den_injective`: den is injective in n (when a ≠ b)
- ✅ `integer_inputs_finite_set`: The set {n ∈ ℤ | den(n) ∣ det} is **finite**

**Proof Strategy**: Since den(n) = (a-b)n + (ab+1) is an injective linear function of n,
and det is a nonzero integer with finitely many divisors, only finitely many values of n
can make den(n) a divisor of det.

### Experiment 3: Matrix Representation

**Hypothesis**: The Möbius transformation F_{a,b} can be represented as a 2×2 integer matrix
with determinant (1+a²)(1+b²).

**Results**:
- ✅ `mobius_matrix_det`: det(M) = (1+a²)(1+b²)
- ✅ `mobius_matrix_trace`: tr(M) = 2(ab+1)
- ✅ `mobius_elliptic`: trace² < 4·det when a ≠ b (all non-trivial maps are elliptic!)

**Key Insight**: The matrix M = [[ab+1, b-a], [a-b, ab+1]] is symmetric about the diagonal
in absolute value. Its eigenvalues are (ab+1) ± i(a-b), which lie on the circle of radius
√((1+a²)(1+b²)). The ellipticity means the map always has finite order on ℙ¹(ℝ).

### Experiment 4: Orbit Theory

**Hypothesis**: Integer inputs pair up: if F_{a,b}(n) = m, then F_{b,a}(m) = n.

**Results**:
- ✅ `orbit_pairing`: If den | num (so F sends n to an integer m), then the reverse map
  F_{b,a} sends m to an integer too (and it's n!)
- ✅ `no_integer_fixed_points`: F_{a,b} has NO integer fixed points when a ≠ b
  (because n² + 1 > 0 for all integers)

**Key Insight**: The orbit pairing is NOT F_{a,b}(n) = m ⟹ F_{a,b}(m) = n (F_{a,b} is
generally not an involution). Rather, F_{b,a} = F_{a,b}⁻¹, so the pairing goes through
the REVERSE map. This was a subtle error in our initial formulation that computational
checking caught: F_{0,1}(-3) = -1/2 ∉ ℤ, but F_{1,0}(-3) = 2 ∈ ℤ.

### Experiment 5: Gaussian Integer Norms

**Results**:
- ✅ `gaussian_norm_multiplicative`: Brahmagupta-Fibonacci identity (both forms)
- ✅ `det_two_representations`: det has two distinct sum-of-squares decompositions
- ✅ `det_pos`: det > 0 always
- ✅ `det_eq_two`: Complete characterization of when det = 2

### Experiment 6: Explicit Computations

**Results**:
- ✅ Verified F_{0,1}: 0↦1, -1↦0, 2↦-3
- ✅ Verified F_{1,0}: -3↦2 (reverse map)
- ✅ Orbit pairings verified computationally: {2,-3} under (F_{0,1}, F_{1,0})
- ✅ Pythagorean connections: poles (1,2)→10, (1,3)→20, (2,3)→50
- ✅ Cryptographic connection: 50 = 5·10 = (1+4)(1+9) uniquely recovers poles 2,3

---

## 📝 Key Discoveries

### 1. The Orbit Pairing Is Not Symmetric
Our initial hypothesis that F_{a,b}(n) = m implies F_{a,b}(m) = n was **wrong**.
The correct statement uses the reverse map: F_{b,a}(m) = n. This is because F_{a,b}
is generally not an involution — it's the composition of two involutions (the pole maps
M_a and M_b), and while each M_a is an involution, their composition F_{a,b} = M_b ∘ M_a
has F_{b,a} = M_a ∘ M_b as its inverse.

### 2. No Integer Fixed Points
The impossibility of integer fixed points (n² + 1 = 0 has no integer solutions) connects
to the fact that -1 is not a quadratic residue mod any prime ≡ 3 (mod 4). Over the
Gaussian integers, n² + 1 = (n+i)(n-i), and the non-existence of integer roots reflects
the irreducibility of x²+1 over ℤ.

### 3. Finiteness Is Constructive
The proof that only finitely many integers map to integers is constructive: we can bound
|n| explicitly. If (a-b)n + (ab+1) divides (1+a²)(1+b²), then
|n| ≤ (|(ab+1)| + |(1+a²)(1+b²)|) / |a-b|.

---

## 🔮 Future Directions

### Still Open
1. **Exact count formula**: How many integers map to integers for given (a,b)?
   This should be related to the number of divisors of (1+a²)(1+b²) that are
   congruent to (ab+1) mod (a-b).

2. **Order of F_{a,b}**: What is the exact order of F_{a,b} as a Möbius transformation?
   The matrix has eigenvalues (ab+1) ± i(a-b), so the order is the smallest k such that
   ((ab+1) + i(a-b))^k is real, i.e., arg((ab+1)+i(a-b)) is a rational multiple of π.

3. **Quaternionic generalization**: On S², the analogous construction should use
   quaternions, with the "determinant" being the product of quaternion norms.

4. **Quantum gate applications**: The normalized Möbius matrices are unitary (up to
   scaling), making them candidates for exact quantum gate synthesis.

---

## 📊 Theorem Count

| File | Theorems | Sorries | Status |
|------|----------|---------|--------|
| InverseStereoMobius.lean | 30+ | 0 | ✅ Complete |
| InverseStereoMobiusNext.lean | 30+ | 0 | ✅ Complete |
| **Total** | **60+** | **0** | ✅ **All verified** |
