"""Assemble PACKAGE.json from the deliverable files in this directory."""
import json, pathlib

here = pathlib.Path(__file__).parent

def read(name: str) -> str:
    return (here / name).read_text()

article = read("ARTICLE.md")
paper = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo = read("demo.py")
viz = read("visualize.py")
html = read("interactive.html")

lean_proofs = r'''-- Catalog/Pythagorean/BourgainSlicing/DiscreteCube.lean
import Mathlib

/-!
# Bourgain's Slicing Problem: the discrete cube is dimension-free isotropic

The uniform probability measure on the discrete cube `{-1, 1}ⁿ` is centred and has
covariance equal to the identity in *every* dimension `n`. Hence every unit linear
functional has variance exactly `1`, independently of `n`: the discrete cube is in
isotropic position with isotropic constant `1`, a dimension-free verification of the
structural premise of the slicing problem.

Main results:
* `sum_coord_eq_zero` — each coordinate sums to zero (centred).
* `covariance` — `T k l = if k = l then 2ⁿ else 0` (identity covariance).
* `E_inner_sq` — `E[⟨θ, x⟩²] = ∑ₖ θₖ²` for every `θ` (isotropy).
* `discreteCube_isotropic` — for a unit functional, `E[⟨θ, x⟩²] = 1`, dimension-free.
* `E_inner` — every linear functional is centred: `E[⟨θ, x⟩] = 0`.
-/

namespace BourgainSlicing

open Finset

variable {n : ℕ}

/-- The value of a sign bit: `true ↦ 1`, `false ↦ -1`. -/
def sgn (b : Bool) : ℝ := if b then 1 else -1

/-- The `i`-th coordinate (a `±1` value) of a point of the discrete cube. -/
def coord (x : Fin n → Bool) (i : Fin n) : ℝ := sgn (x i)

/-- Uniform expectation over the `2ⁿ` points of the discrete cube `{-1,1}ⁿ`. -/
noncomputable def E (f : (Fin n → Bool) → ℝ) : ℝ :=
  (∑ x : Fin n → Bool, f x) / 2 ^ n

/-- Flip the `i`-th sign bit of a cube point. -/
def flip (i : Fin n) (x : Fin n → Bool) : Fin n → Bool :=
  Function.update x i (!(x i))

@[simp] theorem sgn_true : sgn true = 1 := rfl
@[simp] theorem sgn_false : sgn false = -1 := rfl

theorem sgn_not (b : Bool) : sgn (!b) = - sgn b := by
  cases b <;> simp [sgn]

theorem sgn_mul_self (b : Bool) : sgn b * sgn b = 1 := by
  cases b <;> norm_num [sgn]

/-- The number of points of the discrete cube is `2ⁿ`. -/
theorem card_cube : (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
  simp [Fintype.card_fun (α := Fin n) (β := Bool)]

/-- Flipping coordinate `i` is an involution. -/
theorem flip_involutive (i : Fin n) : Function.Involutive (flip i) := by
  intro x
  funext j
  by_cases h : j = i
  · subst h; simp [flip, Function.update_self]
  · simp [flip, Function.update_of_ne h]

/-- Flipping coordinate `i` negates the `i`-th coordinate value. -/
theorem coord_flip_self (i : Fin n) (x : Fin n → Bool) :
    coord (flip i x) i = - coord x i := by
  simp [coord, flip, Function.update_self, sgn_not]

/-- Flipping coordinate `i` leaves coordinate `j ≠ i` unchanged. -/
theorem coord_flip_ne (i j : Fin n) (h : j ≠ i) (x : Fin n → Bool) :
    coord (flip i x) j = coord x j := by
  simp [coord, flip, Function.update_of_ne h]

/-- The permutation of cube points given by flipping coordinate `i`. -/
def flipPerm (i : Fin n) : Equiv.Perm (Fin n → Bool) :=
  (flip_involutive i).toPerm

@[simp] theorem flipPerm_apply (i : Fin n) (x : Fin n → Bool) :
    flipPerm i x = flip i x := rfl

/-- **Centred.** Each coordinate sums to zero over the cube. -/
theorem sum_coord_eq_zero (i : Fin n) :
    ∑ x : Fin n → Bool, coord x i = 0 := by
  have key : ∑ x : Fin n → Bool, coord x i
      = ∑ x : Fin n → Bool, coord (flip i x) i := by
    rw [← Equiv.sum_comp (flipPerm i) (fun x => coord x i)]
    simp
  simp only [coord_flip_self] at key
  rw [Finset.sum_neg_distrib] at key
  linarith

/-- The covariance kernel of the cube: `T k l = ∑ₓ xₖ xₗ`. -/
noncomputable def T (k l : Fin n) : ℝ := ∑ x : Fin n → Bool, coord x k * coord x l

/-- **Off-diagonal covariance vanishes.** For `k ≠ l`, `∑ₓ xₖ xₗ = 0`. -/
theorem T_off_diag {k l : Fin n} (h : k ≠ l) : T k l = 0 := by
  have key : T k l = ∑ x : Fin n → Bool, coord (flip k x) k * coord (flip k x) l := by
    rw [T, ← Equiv.sum_comp (flipPerm k) (fun x => coord x k * coord x l)]
    simp
  simp only [coord_flip_self, coord_flip_ne k l h.symm, neg_mul] at key
  rw [Finset.sum_neg_distrib] at key
  rw [T] at key ⊢
  linarith

/-- **Diagonal covariance.** `∑ₓ xₖ² = 2ⁿ`. -/
theorem T_diag (k : Fin n) : T k k = 2 ^ n := by
  have hone : ∀ x : Fin n → Bool, coord x k * coord x k = 1 := fun x => sgn_mul_self _
  rw [T]
  simp only [hone, Finset.sum_const, card_cube, nsmul_eq_mul, mul_one]
  push_cast
  ring

/-- The covariance kernel is the identity: `T k l = if k = l then 2ⁿ else 0`. -/
theorem covariance (k l : Fin n) : T k l = if k = l then 2 ^ n else 0 := by
  by_cases h : k = l
  · subst h; simp [T_diag]
  · simp [h, T_off_diag h]

/-- **Isotropy (sum form).** `∑ₓ ⟨θ,x⟩² = 2ⁿ · ∑ₖ θₖ²`. -/
theorem sum_inner_sq (θ : Fin n → ℝ) :
    (∑ x : Fin n → Bool, (∑ k, θ k * coord x k) ^ 2)
      = 2 ^ n * ∑ k, (θ k) ^ 2 := by
  have expand : ∀ x : Fin n → Bool,
      (∑ k, θ k * coord x k) ^ 2
        = ∑ k, ∑ l, (θ k * θ l) * (coord x k * coord x l) := by
    intro x
    rw [sq, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl (fun k _ => Finset.sum_congr rfl (fun l _ => by ring))
  simp only [expand]
  have h_sum : ∑ x : Fin n → Bool, ∑ k, ∑ l, θ k * θ l * (coord x k * coord x l)
      = ∑ k, ∑ l, θ k * θ l * T k l := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun k _ => ?_)
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun l _ => by rw [T, Finset.mul_sum])
  rw [h_sum]
  simp only [covariance, mul_ite, mul_zero, Finset.sum_ite_eq, Finset.mem_univ, if_true]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl (fun k _ => by ring)

/-- **Isotropy, expectation form.** `E[⟨θ, x⟩²] = ∑ₖ θₖ²` for every `θ`. -/
theorem E_inner_sq (θ : Fin n → ℝ) :
    E (fun x => (∑ k, θ k * coord x k) ^ 2) = ∑ k, (θ k) ^ 2 := by
  rw [E, sum_inner_sq]
  have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
  field_simp

/-- **Dimension-free isotropy.** For a unit functional, `E[⟨θ, x⟩²] = 1`. -/
theorem discreteCube_isotropic (θ : Fin n → ℝ) (hθ : ∑ k, (θ k) ^ 2 = 1) :
    E (fun x => (∑ k, θ k * coord x k) ^ 2) = 1 := by
  rw [E_inner_sq, hθ]

/-- **Centred functionals.** Every linear functional has expectation zero. -/
theorem E_inner (θ : Fin n → ℝ) : E (fun x => ∑ k, θ k * coord x k) = 0 := by
  rw [E]
  have : ∑ x : Fin n → Bool, ∑ k, θ k * coord x k = 0 := by
    rw [Finset.sum_comm]
    refine Finset.sum_eq_zero (fun k _ => ?_)
    rw [← Finset.mul_sum, sum_coord_eq_zero, mul_zero]
  rw [this, zero_div]

end BourgainSlicing
'''

future_directions = '''# Future Directions — Bourgain's Slicing Problem

This research cycle established a fully verified, dimension-free model of *isotropic position*
for the discrete cube `{-1,1}ⁿ` (`DiscreteCube.lean`), recast it as a Pythagorean/Parseval
identity for an orthonormal coordinate system (`Orthonormality.lean`), and generalised it to
weighted cubes / boxes with a thick-section existence bound (`WeightedCube.lean`). The covariance
is the identity in every dimension, so the discrete cube realises the slicing conjecture with
isotropic constant exactly `1`, uniformly in `n`.

Below are bold but testable conjectures to drive subsequent cycles. Each is stated so it can be
formalised as a Lean theorem (`by sorry` skeleton) and attacked directly.

## Conjecture 1 — Tensorisation of the isotropic constant
For the **product** of the discrete cube model across blocks, the covariance of a product
measure is the block-diagonal sum of the factor covariances, and the (normalised) second moment
of a unit functional is a convex combination of the factor second moments. Concretely: if
`μ = μ₁ ⊗ μ₂` on `(Fin m → Bool) × (Fin n → Bool)`, then for every unit `θ`,
`E_μ[⟨θ,·⟩²] = E_{μ₁}[⟨θ₁,·⟩²] + E_{μ₂}[⟨θ₂,·⟩²]` with `|θ₁|²+|θ₂|² = 1`.
*Testable:* prove the product covariance is block diagonal; deduce that products of isotropic
models are isotropic. This is the discrete shadow of "slicing tensorises over products."

## Conjecture 2 — Affine invariance / shape independence
Every **box** (weighted cube with weights `a : Fin n → ℝ`, all `aₖ ≠ 0`) has, after volume
normalisation, the *same* normalised isotropic functional as the unit cube. Formally, the
covariance `diag(a₁²,…,aₙ²)` rescaled by `(∏ aₖ²)^{-1/n}` has determinant `1`, and the
normalised second moment is independent of `a` up to the affine map. *Testable:* introduce
`Real.rpow`-based normalisation and prove the normalised second-moment functional of the box
equals that of the cube. This formalises affine invariance of the (discrete) isotropic constant.

## Conjecture 3 — Discrete slicing **lower** bound (the hard direction)
Bourgain's conjecture is a uniform LOWER bound on the THINNEST section. In the discrete model:
for the uniform measure on `{-1,1}ⁿ`, every unit functional `θ` satisfies
`min_θ E[⟨θ,x⟩²] = 1` (already an equality here), but for a *general centred product measure*
with bounded coordinates, conjecture `min_{|θ|=1} E[⟨θ,x⟩²] ≥ c · (det Cov)^{1/n}` with a
universal `c > 0`. *Testable:* prove the `c = 1` case for products of symmetric two-point
measures via AM-GM on the eigenvalues `aₖ²`; this is a clean finite analogue of the conjecture.

## Conjecture 4 — Anti-concentration / marginal flatness
The slicing problem is tied to anti-concentration of marginals (`⟨θ,x⟩` has bounded density).
Discrete analogue: for unit `θ`, the distribution of `⟨θ,x⟩` over `{-1,1}ⁿ` has a uniform
upper bound on its point masses, `max_t P[⟨θ,x⟩ = t] ≤ C/√n` for "spread" `θ` (Littlewood–Offord
/ Erdős). *Testable:* formalise this Littlewood–Offord bound for spread coefficient vectors.
'''

algorithm_code = '''from __future__ import annotations

import itertools
from typing import Iterator, List, Tuple


def cube_points(n: int) -> Iterator[Tuple[int, ...]]:
    """Yield each of the 2^n corners of {-1,1}^n as a tuple of +-1 integers."""
    for bits in itertools.product((1, -1), repeat=n):
        yield bits


def exact_covariance_kernel(n: int) -> List[List[int]]:
    """Compute T(k,l) = sum_x coord(x,k) coord(x,l) by exhaustive enumeration.

    Returns the integer matrix T. By the covariance theorem it equals 2^n * I_n:
    diagonal entries are 2^n and off-diagonal entries are 0, in every dimension.

    Complexity: Theta(2^n * n^2) time, Theta(n^2) space.
    """
    T: List[List[int]] = [[0] * n for _ in range(n)]
    for x in cube_points(n):
        for k in range(n):
            xk = x[k]
            for l in range(n):
                T[k][l] += xk * x[l]
    return T


def is_identity_times(T: List[List[int]], scale: int) -> bool:
    """Check that T equals scale * I (the covariance theorem's prediction)."""
    n = len(T)
    for k in range(n):
        for l in range(n):
            expected = scale if k == l else 0
            if T[k][l] != expected:
                return False
    return True


def verify_covariance(n: int) -> bool:
    """Verify T = 2^n * I_n for the discrete cube of dimension n."""
    return is_identity_times(exact_covariance_kernel(n), 2 ** n)
'''

algorithm_code_2 = '''from __future__ import annotations

import itertools
import math
from typing import List


def expected_inner_sq(n: int, theta: List[float]) -> float:
    """Exact E[<theta,x>^2] over {-1,1}^n by enumeration; predicted = sum theta_k^2.

    Complexity: Theta(2^n * n) time, Theta(1) extra space.
    """
    total = 0.0
    for bits in itertools.product((1, -1), repeat=n):
        s = 0.0
        for k in range(n):
            s += theta[k] * bits[k]
        total += s * s
    return total / (2 ** n)


def normalize(theta: List[float]) -> List[float]:
    """Return the Euclidean-unit direction of theta."""
    norm = math.sqrt(sum(t * t for t in theta))
    if norm == 0.0:
        raise ValueError("zero vector has no direction")
    return [t / norm for t in theta]


def isotropic_constant(n: int, theta: List[float]) -> float:
    """E[<u,x>^2] for the unit direction u = theta/|theta|; the theorem says it is 1."""
    return expected_inner_sq(n, normalize(theta))
'''

package = {
    "title": "The Discrete Cube as a Dimension-Free Isotropic Body: A Verified Model for Bourgain's Slicing Problem",
    "domain": "Pythagorean",
    "description": "A fully verified, measure-theory-free model of isotropic position: the uniform measure on the discrete cube {-1,1}^n has identity covariance in every dimension, so every unit linear functional has variance exactly 1, realizing the structural premise of Bourgain's slicing problem with isotropic constant 1 uniformly in n.",
    "authors": ["Aristotle"],
    "date": "2026-06-26",
    "key_results": [
        "sum_coord_eq_zero: each coordinate sums to zero over the cube (the uniform measure is centered)",
        "covariance: the covariance kernel T(k,l) = sum_x coord(x,k) coord(x,l) equals 2^n if k=l and 0 otherwise (identity covariance)",
        "E_inner_sq: E[<theta,x>^2] = sum_k theta_k^2 for every theta (Pythagorean second-moment identity)",
        "discreteCube_isotropic: for a unit functional, E[<theta,x>^2] = 1, independently of the dimension n",
        "E_inner: every linear functional is centered, E[<theta,x>] = 0",
    ],
    "keywords": [
        "Bourgain slicing problem",
        "hyperplane conjecture",
        "isotropic position",
        "isotropic constant",
        "covariance matrix",
        "discrete cube",
        "sign-flip involution",
        "Pythagorean identity",
    ],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "Exhaustive Verification of Dimension-Free Cube Isotropy",
            "description": "Enumerates all 2^n corners of the discrete cube to verify the full chain of main theorems: every coordinate sums to zero (sum_coord_eq_zero), the covariance kernel equals 2^n times the identity (covariance), the second moment of any functional equals its squared Euclidean norm (E_inner_sq), and a random unit functional has variance exactly 1 in every dimension from 1 to 12 (discreteCube_isotropic). A Monte Carlo cross-check confirms the dimension-free constant 1 at dimension n=200 where enumeration is infeasible.",
            "code": demo,
        }
    ],
    "algorithms": [
        {
            "name": "Exact Covariance Kernel by Exhaustive Corner Enumeration",
            "description": "Computes the covariance kernel T(k,l) = sum over all 2^n cube corners of coord(x,k)*coord(x,l) and checks it equals 2^n * I_n, directly certifying the covariance theorem. The diagonal is 2^n because (+-1)^2 = 1 at every corner; the off-diagonal vanishes because flipping coordinate k sends the summand to its negative. Runs in Theta(2^n * n^2) time and Theta(n^2) space; practical for n up to about 20.",
            "pseudocode": "function exact_covariance_kernel(n):\n    T <- n x n integer matrix of zeros\n    for each bit-string x in {-1,+1}^n:        # 2^n corners\n        for k in 0..n-1:\n            for l in 0..n-1:\n                T[k][l] <- T[k][l] + x[k]*x[l]\n    return T\n\nfunction verify_covariance(n):\n    T <- exact_covariance_kernel(n)\n    for k in 0..n-1, l in 0..n-1:\n        expected <- (2^n if k == l else 0)\n        if T[k][l] != expected: return false\n    return true",
            "code": algorithm_code,
        },
        {
            "name": "Directional Second-Moment Isotropy Estimator",
            "description": "Given a direction theta, normalizes it to unit length and computes E[<theta,x>^2] exactly by enumerating the cube. By the isotropy theorem the result equals sum_k theta_k^2, and for a unit direction it equals 1 in every dimension. Runs in Theta(2^n * n) time. This is the computational witness of dimension-free isotropy (discreteCube_isotropic).",
            "pseudocode": "function isotropic_constant(n, theta):\n    u <- theta / euclidean_norm(theta)        # unit direction\n    total <- 0\n    for each bit-string x in {-1,+1}^n:        # 2^n corners\n        s <- sum_k u[k]*x[k]\n        total <- total + s*s\n    return total / 2^n                          # equals 1 by the theorem",
            "code": algorithm_code_2,
        },
    ],
    "visualizations": [
        {
            "name": "Identity Covariance Heatmap and Dimension-Free Constant Chart",
            "description": "Two figures: (1) a heatmap of the normalized covariance matrix T/2^n showing it is exactly the identity, and (2) a bar chart of E[<theta,x>^2] for a random unit theta across dimensions n = 1..12, pinned to the predicted value 1 with no dependence on n.",
            "code": viz,
        }
    ],
    "interactive_demos": [
        {
            "title": "Discrete Cube Isotropy Explorer: Covariance and Marginal Variance",
            "description": "An interactive widget where the reader varies the dimension n to watch the covariance kernel T/2^n remain the identity, and adjusts the components of a direction theta (auto-normalized to unit length) to see the measured second moment E[<theta,x>^2] stay pinned at 1, alongside a live histogram of the marginal <theta,x> over all 2^n corners centered at zero.",
            "html": html,
        }
    ],
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": ["Catalog/Pythagorean/BourgainSlicing/DiscreteCube.lean"],
}

(here / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("PACKAGE.json written:", (here / "PACKAGE.json").stat().st_size, "bytes")


"""Numerical demonstrations for the discrete-cube model of Bourgain's slicing problem.

This script verifies, by exhaustive enumeration of the 2^n corners of the discrete
cube {-1,1}^n, the structural theorems from the accompanying Lean development:

  * sum_coord_eq_zero  -- each coordinate sums to zero over the cube (centering)
  * covariance         -- T(k,l) = sum_x coord(x,k) coord(x,l) = 2^n * [k == l]
  * E_inner_sq         -- E[<theta, x>^2] = sum_k theta_k^2  (Pythagorean isotropy)
  * discreteCube_isotropic -- for a unit theta, E[<theta, x>^2] = 1, dimension-free
  * E_inner            -- E[<theta, x>] = 0 (functionals are centered)

Everything is self-contained: only the Python standard library is used.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Iterator, List, Tuple


# ---------------------------------------------------------------------------
# Core model: the discrete cube {-1, 1}^n
# ---------------------------------------------------------------------------

def cube_points(n: int) -> Iterator[Tuple[int, ...]]:
    """Yield each of the 2^n corners of {-1, 1}^n as a tuple of +-1 integers.

    This mirrors the Lean type `Fin n -> Bool` via `coord x i = sgn (x i)`.
    """
    for bits in itertools.product((True, False), repeat=n):
        yield tuple(1 if b else -1 for b in bits)


def card_cube(n: int) -> int:
    """Number of cube points; equals 2^n (Lean: `card_cube`)."""
    return 2 ** n


# ---------------------------------------------------------------------------
# Theorem A: centering of coordinates (Lean: sum_coord_eq_zero)
# ---------------------------------------------------------------------------

def sum_coordinate(n: int, i: int) -> int:
    """Return sum_x coord(x, i) over the whole cube; the theorem says it is 0."""
    return sum(x[i] for x in cube_points(n))


def demo_centering(n: int) -> None:
    print(f"[Theorem A] Centering of coordinates in dimension n = {n}")
    for i in range(n):
        s = sum_coordinate(n, i)
        assert s == 0, f"coordinate {i} did not sum to zero: {s}"
        print(f"    sum_x coord(x,{i}) = {s}")
    print("    -> every coordinate sums to exactly 0 (cube is centered).\n")


# ---------------------------------------------------------------------------
# Theorem B: covariance kernel is the identity (Lean: covariance / T_diag / T_off_diag)
# ---------------------------------------------------------------------------

def covariance_kernel(n: int) -> List[List[int]]:
    """Return the matrix T(k,l) = sum_x coord(x,k) coord(x,l)."""
    T = [[0 for _ in range(n)] for _ in range(n)]
    for x in cube_points(n):
        for k in range(n):
            for l in range(n):
                T[k][l] += x[k] * x[l]
    return T


def demo_covariance(n: int) -> None:
    print(f"[Theorem B] Covariance kernel T(k,l) in dimension n = {n}")
    T = covariance_kernel(n)
    expected_diag = 2 ** n
    for k in range(n):
        for l in range(n):
            want = expected_diag if k == l else 0
            assert T[k][l] == want, f"T[{k}][{l}] = {T[k][l]} != {want}"
    print(f"    T = {expected_diag} * Identity_{n}  (diagonal = 2^n = {expected_diag}, off-diagonal = 0)")
    for row in T:
        print("    " + "  ".join(f"{v:5d}" for v in row))
    print("    -> covariance matrix (T / 2^n) is exactly the identity.\n")


# ---------------------------------------------------------------------------
# Theorem C / D: second-moment isotropy (Lean: E_inner_sq, discreteCube_isotropic)
# ---------------------------------------------------------------------------

def expected_inner(n: int, theta: List[float]) -> float:
    """E[<theta, x>] over the cube (Lean: E_inner); the theorem says it is 0."""
    total = 0.0
    for x in cube_points(n):
        total += sum(theta[k] * x[k] for k in range(n))
    return total / card_cube(n)


def expected_inner_sq(n: int, theta: List[float]) -> float:
    """E[<theta, x>^2] over the cube (Lean: E_inner_sq)."""
    total = 0.0
    for x in cube_points(n):
        s = sum(theta[k] * x[k] for k in range(n))
        total += s * s
    return total / card_cube(n)


def unit(theta: List[float]) -> List[float]:
    """Normalize theta to Euclidean unit length."""
    norm = math.sqrt(sum(t * t for t in theta))
    if norm == 0.0:
        raise ValueError("zero vector has no unit direction")
    return [t / norm for t in theta]


def demo_isotropy(n: int, thetas: List[List[float]]) -> None:
    print(f"[Theorems C & D] Second-moment isotropy in dimension n = {n}")
    for raw in thetas:
        theta = list(raw)
        sum_sq = sum(t * t for t in theta)
        lhs = expected_inner_sq(n, theta)
        mean = expected_inner(n, theta)
        assert math.isclose(lhs, sum_sq, rel_tol=1e-12, abs_tol=1e-12)
        assert math.isclose(mean, 0.0, abs_tol=1e-12)
        print(f"    theta = {theta}")
        print(f"        E[<theta,x>]   = {mean:.12f}   (predicted 0)")
        print(f"        E[<theta,x>^2] = {lhs:.12f}   (predicted sum theta_k^2 = {sum_sq:.12f})")
    print("    -> second moment equals the squared Euclidean norm (Pythagorean identity).\n")


def demo_dimension_free(max_n: int = 12) -> None:
    """Show that a *unit* functional has E[<theta,x>^2] = 1 in every dimension."""
    print("[Theorem D] Dimension-free isotropy: unit functional has variance 1 for all n")
    rng = random.Random(20260626)
    for n in range(1, max_n + 1):
        theta = unit([rng.uniform(-1.0, 1.0) for _ in range(n)])
        val = expected_inner_sq(n, theta)
        assert math.isclose(val, 1.0, rel_tol=1e-12, abs_tol=1e-12)
        print(f"    n = {n:2d}:  E[<theta,x>^2] = {val:.12f}  (random unit theta)")
    print("    -> exactly 1 in every dimension, independent of n.\n")


# ---------------------------------------------------------------------------
# Monte Carlo cross-check of dimension-free isotropy for large n
# ---------------------------------------------------------------------------

def monte_carlo_inner_sq(n: int, theta: List[float], samples: int, seed: int = 0) -> float:
    """Estimate E[<theta,x>^2] by sampling random cube corners (no enumeration)."""
    rng = random.Random(seed)
    total = 0.0
    for _ in range(samples):
        s = sum(theta[k] * (1 if rng.random() < 0.5 else -1) for k in range(n))
        total += s * s
    return total / samples


def demo_monte_carlo(n: int = 200, samples: int = 200_000) -> None:
    print(f"[Theorem D, Monte Carlo] Large dimension n = {n} (enumeration infeasible)")
    rng = random.Random(7)
    theta = unit([rng.uniform(-1.0, 1.0) for _ in range(n)])
    est = monte_carlo_inner_sq(n, theta, samples, seed=123)
    print(f"    samples = {samples}, estimate E[<theta,x>^2] ~ {est:.6f}  (predicted 1)")
    print("    -> concentrates around 1 even in high dimension.\n")


def main() -> None:
    print("=" * 72)
    print("Discrete-cube model of Bourgain's slicing problem -- numerical demos")
    print("=" * 72 + "\n")

    demo_centering(n=4)
    demo_covariance(n=4)
    demo_isotropy(
        n=5,
        thetas=[
            [1.0, 0.0, 0.0, 0.0, 0.0],
            [1.0, 1.0, 1.0, 1.0, 1.0],
            [3.0, -1.0, 2.0, 0.5, -2.5],
        ],
    )
    demo_dimension_free(max_n=12)
    demo_monte_carlo(n=200, samples=200_000)

    print("All assertions passed: the discrete cube is exactly isotropic, dimension-free.")


if __name__ == "__main__":
    main()


"""Visualizations for the discrete-cube isotropy model of Bourgain's slicing problem.

Produces two figures:
  1. A heatmap of the covariance kernel T(k,l)/2^n, showing it is the identity.
  2. A bar chart of E[<theta,x>^2] for a random unit theta across dimensions n,
     showing the dimension-free constant value 1.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import List, Tuple

import numpy as np
import matplotlib.pyplot as plt


def covariance_matrix(n: int) -> np.ndarray:
    """Normalized covariance matrix T(k,l)/2^n of the uniform measure on {-1,1}^n."""
    M = np.zeros((n, n))
    for bits in itertools.product((1, -1), repeat=n):
        x = np.array(bits, dtype=float)
        M += np.outer(x, x)
    return M / (2 ** n)


def expected_inner_sq(n: int, theta: List[float]) -> float:
    total = 0.0
    for bits in itertools.product((1, -1), repeat=n):
        s = sum(theta[k] * bits[k] for k in range(n))
        total += s * s
    return total / (2 ** n)


def unit(theta: List[float]) -> List[float]:
    norm = math.sqrt(sum(t * t for t in theta))
    return [t / norm for t in theta]


def make_figures() -> Tuple[plt.Figure, plt.Figure]:
    # Figure 1: covariance heatmap.
    n = 6
    M = covariance_matrix(n)
    fig1, ax1 = plt.subplots(figsize=(5, 4))
    im = ax1.imshow(M, cmap="viridis", vmin=0.0, vmax=1.0)
    ax1.set_title(f"Normalized covariance T/2^n  (n = {n}) = Identity")
    ax1.set_xlabel("coordinate l")
    ax1.set_ylabel("coordinate k")
    fig1.colorbar(im, ax=ax1)

    # Figure 2: dimension-free constant.
    rng = random.Random(20260626)
    ns = list(range(1, 13))
    vals = [expected_inner_sq(n, unit([rng.uniform(-1, 1) for _ in range(n)])) for n in ns]
    fig2, ax2 = plt.subplots(figsize=(6, 4))
    ax2.bar(ns, vals, color="#3b78b0")
    ax2.axhline(1.0, color="crimson", linestyle="--", label="predicted value 1")
    ax2.set_ylim(0, 1.4)
    ax2.set_title("E[<theta,x>^2] for a unit theta is 1 in every dimension")
    ax2.set_xlabel("dimension n")
    ax2.set_ylabel("E[<theta,x>^2]")
    ax2.legend()
    return fig1, fig2


def main() -> None:
    fig1, fig2 = make_figures()
    fig1.savefig("covariance_identity.png", dpi=150, bbox_inches="tight")
    fig2.savefig("dimension_free_constant.png", dpi=150, bbox_inches="tight")
    print("Saved covariance_identity.png and dimension_free_constant.png")


if __name__ == "__main__":
    main()
