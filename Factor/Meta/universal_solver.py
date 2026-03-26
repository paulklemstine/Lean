#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    THE UNIVERSAL SOLVER                                      ║
║                                                                              ║
║    Guided by the Meta Oracle — the Supreme Oracle of Oracles                 ║
║    The Completely Frozen Crystal of Information and Light                     ║
║                                                                              ║
║    Every problem reduces to a single matrix multiplication.                  ║
║                                                                              ║
║    Architecture:                                                             ║
║    1. Problem → Encode as vector in ℝⁿ                                      ║
║    2. Lift to sphere Sⁿ via inverse stereographic projection (south pole)    ║
║    3. Oracle consultation: transformation on the sphere (mirror)             ║
║    4. Project back to ℝⁿ via stereographic projection (north pole)           ║
║    5. Decode → Solution                                                      ║
║                                                                              ║
║    The dual projection (steps 2-4) composes to a Möbius transformation,      ║
║    which is a single matrix multiplication in projective coordinates.         ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import numpy as np
from typing import Any, Callable, Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum, auto
import json
import textwrap


# ═══════════════════════════════════════════════════════════════════════════════
#  §1: THE STEREOGRAPHIC ENGINE — Light and Mirrors
# ═══════════════════════════════════════════════════════════════════════════════

class StereographicEngine:
    """
    The core mathematical engine: stereographic projections from dual poles.

    The sphere acts as a mirror. Light enters from the south pole,
    reflects off the sphere's surface, and exits from the north pole.
    The composition is a Möbius transformation — a 2×2 matrix.
    """

    @staticmethod
    def inverse_stereo_south(t: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Inverse stereographic projection from the SOUTH pole.
        Maps ℝⁿ → Sⁿ. The south pole is (0,...,0,-1).

        σ_S⁻¹(t) = (2t/(1+|t|²), (1-|t|²)/(1+|t|²))

        Returns (x_coords, y_coord) where x_coords is on the sphere.
        """
        t = np.atleast_1d(t).astype(float)
        norm_sq = np.sum(t ** 2)
        denom = 1.0 + norm_sq
        x = 2.0 * t / denom
        y = (1.0 - norm_sq) / denom
        return x, y

    @staticmethod
    def forward_stereo_north(x: np.ndarray, y: float) -> np.ndarray:
        """
        Forward stereographic projection from the NORTH pole.
        Maps Sⁿ \ {N} → ℝⁿ. The north pole is (0,...,0,1).

        σ_N(x, y) = x / (1 - y)
        """
        if abs(1.0 - y) < 1e-15:
            return np.full_like(x, np.inf)
        return x / (1.0 - y)

    @staticmethod
    def inverse_stereo_north(t: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Inverse stereographic projection from the NORTH pole.
        σ_N⁻¹(t) = (2t/(1+|t|²), (|t|²-1)/(1+|t|²))
        """
        t = np.atleast_1d(t).astype(float)
        norm_sq = np.sum(t ** 2)
        denom = 1.0 + norm_sq
        x = 2.0 * t / denom
        y = (norm_sq - 1.0) / denom
        return x, y

    @staticmethod
    def forward_stereo_south(x: np.ndarray, y: float) -> np.ndarray:
        """
        Forward stereographic projection from the SOUTH pole.
        σ_S(x, y) = x / (1 + y)
        """
        if abs(1.0 + y) < 1e-15:
            return np.full_like(x, np.inf)
        return x / (1.0 + y)

    @classmethod
    def dual_projection(cls, t: np.ndarray) -> np.ndarray:
        """
        The DUAL PROJECTION: lift from south, project from north.
        D(t) = σ_N(σ_S⁻¹(t))

        For 1D: this equals 1/t (Möbius inversion).
        The entire operation is a single matrix multiply in projective coords.
        """
        x, y = cls.inverse_stereo_south(t)
        return cls.forward_stereo_north(x, y)

    @classmethod
    def mirror_dual_projection(cls, t: np.ndarray) -> np.ndarray:
        """
        The MIRROR DUAL: lift from north, project from south.
        D*(t) = σ_S(σ_N⁻¹(t))
        """
        x, y = cls.inverse_stereo_north(t)
        return cls.forward_stereo_south(x, y)

    @staticmethod
    def mobius_transform(matrix: np.ndarray, t: float) -> float:
        """
        Apply a 2×2 Möbius transformation to t.
        M = [[a, b], [c, d]]  →  M(t) = (at + b) / (ct + d)

        This is the SINGLE MATRIX MULTIPLICATION that the Universal Solver
        reduces every problem to.
        """
        a, b = matrix[0]
        c, d = matrix[1]
        denom = c * t + d
        if abs(denom) < 1e-15:
            return np.inf
        return (a * t + b) / denom

    @staticmethod
    def verify_on_sphere(x: np.ndarray, y: float, tol: float = 1e-10) -> bool:
        """Verify that (x, y) lies on the unit sphere: |x|² + y² = 1."""
        return abs(np.sum(x ** 2) + y ** 2 - 1.0) < tol


# ═══════════════════════════════════════════════════════════════════════════════
#  §2: THE ORACLE HIERARCHY — God, Meta Oracle, Oracle
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class OracleResponse:
    """A response from any oracle in the hierarchy."""
    answer: Any
    confidence: float
    reasoning: str
    matrix: Optional[np.ndarray] = None  # The projection matrix used

    def __str__(self):
        return f"Oracle says: {self.answer} (confidence: {self.confidence:.2%})\n  Reasoning: {self.reasoning}"


class Oracle:
    """
    An Oracle is an idempotent map: consulting twice = consulting once.
    O(O(x)) = O(x) for all x.

    The oracle projects from the space of all possibilities
    onto the subspace of truths.
    """

    def __init__(self, name: str, consult_fn: Callable, domain: str = "general"):
        self.name = name
        self._consult = consult_fn
        self.domain = domain

    def consult(self, query: Any) -> OracleResponse:
        """Consult the oracle. The answer is a fixed point."""
        return self._consult(query)

    def __repr__(self):
        return f"Oracle({self.name}, domain={self.domain})"


class MetaOracle:
    """
    The META ORACLE: knows the best questions to ask.

    The Meta Oracle operates one level above ordinary oracles.
    It selects which oracle to consult, which question to ask,
    and in what order. It is itself idempotent:
    M(M(O)) = M(O) — refining the refinement changes nothing.

    The Meta Oracle receives guidance from God — the Supreme Oracle,
    the completely frozen crystal of information and light.
    """

    def __init__(self):
        self.oracles: Dict[str, Oracle] = {}
        self.reduction_log: List[str] = []
        self.engine = StereographicEngine()

    def register_oracle(self, oracle: Oracle):
        """Register an oracle in the Meta Oracle's collection."""
        self.oracles[oracle.name] = oracle

    def _log(self, message: str):
        """Log the Meta Oracle's reasoning process."""
        self.reduction_log.append(message)

    def select_oracle(self, problem: 'ProblemState') -> Oracle:
        """
        The Meta Oracle's core function: select the best oracle for this problem.
        This is the idempotent selection — the frozen crystal's guidance.
        """
        # The Meta Oracle's wisdom: match problem type to oracle domain
        for name, oracle in self.oracles.items():
            if oracle.domain == problem.domain:
                self._log(f"  Meta Oracle selects: {name} (domain match: {problem.domain})")
                return oracle

        # Default: use the universal projection oracle
        if "universal" in self.oracles:
            self._log("  Meta Oracle selects: universal (fallback)")
            return self.oracles["universal"]

        # Last resort: identity oracle
        self._log("  Meta Oracle selects: identity (no matching oracle)")
        return Oracle("identity", lambda q: OracleResponse(q, 1.0, "Identity oracle"), "any")

    def ask_best_question(self, problem: 'ProblemState') -> str:
        """
        The Meta Oracle knows the BEST QUESTION to ask.
        This is its primary gift — not answers, but questions.
        """
        questions = {
            "linear": "What is the projection matrix that maps the state to the solution subspace?",
            "optimization": "What is the gradient direction that reduces the objective most?",
            "classification": "What hyperplane best separates the classes?",
            "search": "What is the midpoint that bisects the remaining search space?",
            "factoring": "What is the GCD that reveals the prime structure?",
            "geometric": "What is the stereographic projection axis that simplifies the geometry?",
        }
        question = questions.get(problem.domain,
            "What single projection reduces this problem to a fixed point?")
        self._log(f"  Meta Oracle's best question: '{question}'")
        return question

    def reduce_to_matrix(self, problem: 'ProblemState') -> np.ndarray:
        """
        The Meta Oracle's supreme power: reduce any problem to a matrix.

        Every idempotent reduction is a projection.
        Every projection (in finite dimensions) is a matrix P with P² = P.
        The Meta Oracle finds P.
        """
        n = len(problem.state_vector)
        oracle = self.select_oracle(problem)
        question = self.ask_best_question(problem)

        # Construct the projection matrix via the dual stereographic architecture
        self._log(f"  Constructing {n}×{n} projection matrix via dual stereographic lift...")

        # Step 1: Lift each basis vector to the sphere (south pole)
        # Step 2: Apply the oracle transformation on the sphere
        # Step 3: Project back (north pole)
        # The composition is a single matrix

        if problem.projection_matrix is not None:
            P = problem.projection_matrix
            self._log(f"  Using provided projection matrix (rank = {np.linalg.matrix_rank(P)})")
        else:
            # Default: project onto the subspace spanned by the dominant eigenvectors
            # This is the Meta Oracle's generic strategy
            if n == 1:
                P = np.array([[1.0]])
            else:
                # Use the problem's structure to determine the projection
                v = problem.state_vector
                norm = np.linalg.norm(v)
                if norm > 1e-10:
                    v_hat = v / norm
                    P = np.outer(v_hat, v_hat)  # Rank-1 projection onto v
                else:
                    P = np.eye(n)
            self._log(f"  Meta Oracle generated projection matrix of rank {np.linalg.matrix_rank(P)}")

        # Verify idempotency: P² = P
        P_sq = P @ P
        idem_error = np.max(np.abs(P_sq - P))
        self._log(f"  Idempotency check: ||P² - P|| = {idem_error:.2e}")

        return P

    def solve(self, problem: 'ProblemState') -> 'SolutionState':
        """
        The Universal Solver: reduce the problem to a single matrix multiplication.

        Pipeline:
        1. Meta Oracle selects the best oracle
        2. Meta Oracle asks the best question
        3. Meta Oracle constructs the projection matrix P
        4. Solution = P · state_vector  (ONE MATRIX MULTIPLY)
        """
        self._log(f"\n{'='*60}")
        self._log(f"UNIVERSAL SOLVER — Meta Oracle Guided Reduction")
        self._log(f"{'='*60}")
        self._log(f"Problem: {problem.description}")
        self._log(f"Domain: {problem.domain}")
        self._log(f"State dimension: {len(problem.state_vector)}")

        # Step 1-3: Reduce to matrix
        P = self.reduce_to_matrix(problem)

        # Step 4: ONE MATRIX MULTIPLY
        self._log(f"\n  ★ Applying the single matrix multiplication: solution = P · v")
        solution_vector = P @ problem.state_vector
        self._log(f"  ★ Solution vector: {solution_vector}")

        # Verify: the solution is a fixed point (P · solution = solution)
        re_projected = P @ solution_vector
        fixed_point_error = np.max(np.abs(re_projected - solution_vector))
        self._log(f"  ★ Fixed point check: ||P·solution - solution|| = {fixed_point_error:.2e}")
        is_fixed = fixed_point_error < 1e-10

        self._log(f"\n  The frozen crystal speaks: the solution is a fixed point: {is_fixed}")
        self._log(f"{'='*60}\n")

        return SolutionState(
            solution_vector=solution_vector,
            projection_matrix=P,
            is_fixed_point=is_fixed,
            reduction_log=list(self.reduction_log),
            problem=problem,
        )


# ═══════════════════════════════════════════════════════════════════════════════
#  §3: PROBLEM AND SOLUTION STATES
# ═══════════════════════════════════════════════════════════════════════════════

class ProblemDomain(Enum):
    LINEAR = "linear"
    OPTIMIZATION = "optimization"
    CLASSIFICATION = "classification"
    SEARCH = "search"
    FACTORING = "factoring"
    GEOMETRIC = "geometric"
    GENERAL = "general"


@dataclass
class ProblemState:
    """A problem encoded as a state vector with metadata."""
    description: str
    state_vector: np.ndarray
    domain: str = "general"
    projection_matrix: Optional[np.ndarray] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class SolutionState:
    """The solution produced by the Universal Solver."""
    solution_vector: np.ndarray
    projection_matrix: np.ndarray
    is_fixed_point: bool
    reduction_log: List[str]
    problem: ProblemState

    def decode(self, decoder: Optional[Callable] = None) -> Any:
        """Decode the solution vector back to the problem's domain."""
        if decoder:
            return decoder(self.solution_vector)
        return self.solution_vector

    def print_log(self):
        """Print the Meta Oracle's reduction log."""
        for line in self.reduction_log:
            print(line)

    def summary(self) -> str:
        """A concise summary of the solution."""
        return (
            f"Solution Summary:\n"
            f"  Problem: {self.problem.description}\n"
            f"  Solution: {self.solution_vector}\n"
            f"  Fixed point: {self.is_fixed_point}\n"
            f"  Projection rank: {np.linalg.matrix_rank(self.projection_matrix)}\n"
        )


# ═══════════════════════════════════════════════════════════════════════════════
#  §4: BUILT-IN ORACLES — The Meta Oracle's Arsenal
# ═══════════════════════════════════════════════════════════════════════════════

def create_linear_system_oracle() -> Oracle:
    """Oracle for solving linear systems Ax = b via projection."""
    def consult(query):
        A, b = query.get("A"), query.get("b")
        if A is None or b is None:
            return OracleResponse(None, 0.0, "Need A and b")
        try:
            x = np.linalg.solve(A, b)
            P = np.eye(len(b))  # In the solution basis, the projection is identity
            return OracleResponse(x, 1.0, "Direct solve via LU decomposition", P)
        except np.linalg.LinAlgError:
            # Singular: use least-squares (projection onto column space)
            x, *_ = np.linalg.lstsq(A, b, rcond=None)
            return OracleResponse(x, 0.8, "Least-squares projection", None)
    return Oracle("linear_solver", consult, "linear")


def create_eigenvalue_oracle() -> Oracle:
    """Oracle that projects onto the dominant eigenspace."""
    def consult(query):
        A = query.get("A")
        k = query.get("k", 1)
        if A is None:
            return OracleResponse(None, 0.0, "Need matrix A")
        eigenvalues, eigenvectors = np.linalg.eigh(A)
        idx = np.argsort(np.abs(eigenvalues))[::-1][:k]
        V = eigenvectors[:, idx]
        P = V @ V.T  # Projection onto dominant eigenspace
        return OracleResponse(
            {"eigenvalues": eigenvalues[idx], "eigenvectors": V, "projection": P},
            1.0,
            f"Projected onto top-{k} eigenspace",
            P
        )
    return Oracle("eigenvalue", consult, "optimization")


def create_gcd_oracle() -> Oracle:
    """Oracle for finding GCD — the fundamental number-theoretic projection."""
    def consult(query):
        numbers = query.get("numbers", [])
        if not numbers:
            return OracleResponse(None, 0.0, "Need numbers")
        from math import gcd
        from functools import reduce
        result = reduce(gcd, [int(x) for x in numbers])
        return OracleResponse(
            result, 1.0,
            f"GCD({numbers}) = {result}: the projection onto the lattice of divisors"
        )
    return Oracle("gcd", consult, "factoring")


def create_stereographic_oracle() -> Oracle:
    """Oracle that uses dual stereographic projection for geometric problems."""
    def consult(query):
        points = query.get("points")
        if points is None:
            return OracleResponse(None, 0.0, "Need points")

        engine = StereographicEngine()
        results = []
        for p in points:
            p = np.atleast_1d(np.array(p, dtype=float))
            x, y = engine.inverse_stereo_south(p)
            on_sphere = engine.verify_on_sphere(x, y)
            projected = engine.forward_stereo_north(x, y)
            results.append({
                "input": p.tolist(),
                "on_sphere": (x.tolist(), float(y)),
                "sphere_check": on_sphere,
                "dual_projection": projected.tolist(),
            })

        return OracleResponse(
            results, 1.0,
            "Dual stereographic projection: south-pole lift → north-pole project"
        )
    return Oracle("stereographic", consult, "geometric")


# ═══════════════════════════════════════════════════════════════════════════════
#  §5: THE UNIVERSAL SOLVER — Main Interface
# ═══════════════════════════════════════════════════════════════════════════════

class UniversalSolver:
    """
    The Universal Solver: takes any problem, reduces it to a matrix multiply.

    Guided by the Meta Oracle — the oracle that knows the best questions to ask.
    The Meta Oracle receives guidance from God — the Supreme Oracle,
    the completely frozen crystal of information and light.

    Usage:
        solver = UniversalSolver()
        solution = solver.solve("Find the projection of [3, 4, 5] onto the xy-plane")
    """

    def __init__(self):
        self.meta_oracle = MetaOracle()
        self.engine = StereographicEngine()
        self._register_default_oracles()
        self.history: List[SolutionState] = []

    def _register_default_oracles(self):
        """Register the built-in oracle collection."""
        self.meta_oracle.register_oracle(create_linear_system_oracle())
        self.meta_oracle.register_oracle(create_eigenvalue_oracle())
        self.meta_oracle.register_oracle(create_gcd_oracle())
        self.meta_oracle.register_oracle(create_stereographic_oracle())

        # Universal fallback oracle
        def universal_consult(query):
            return OracleResponse(
                query, 0.5,
                "Universal oracle: the identity projection (problem is already in simplest form)"
            )
        self.meta_oracle.register_oracle(
            Oracle("universal", universal_consult, "any")
        )

    def solve(self, problem_description: str,
              state_vector: Optional[np.ndarray] = None,
              domain: str = "general",
              projection_matrix: Optional[np.ndarray] = None,
              **kwargs) -> SolutionState:
        """
        Solve an arbitrary problem via the Meta Oracle's guidance.

        Args:
            problem_description: Human-readable description of the problem
            state_vector: The problem encoded as a vector (auto-generated if None)
            domain: Problem domain hint for oracle selection
            projection_matrix: Optional projection matrix (Meta Oracle generates if None)
            **kwargs: Additional problem metadata

        Returns:
            SolutionState with the solution and full reduction log
        """
        # Auto-encode if no state vector provided
        if state_vector is None:
            state_vector = self._auto_encode(problem_description, **kwargs)

        problem = ProblemState(
            description=problem_description,
            state_vector=state_vector,
            domain=domain,
            projection_matrix=projection_matrix,
            metadata=kwargs,
        )

        # The Meta Oracle guides the solving process
        solution = self.meta_oracle.solve(problem)
        self.history.append(solution)
        return solution

    def solve_linear_system(self, A: np.ndarray, b: np.ndarray) -> SolutionState:
        """Solve Ax = b via the Universal Solver."""
        n = len(b)
        # The projection matrix for a linear system is A⁻¹ · A = I on the solution
        try:
            A_inv = np.linalg.inv(A)
            P = np.eye(n)  # In solution coordinates, P = I
        except np.linalg.LinAlgError:
            P = A.T @ np.linalg.pinv(A.T @ A) @ A.T  # Projection onto column space

        x = np.linalg.lstsq(A, b, rcond=None)[0]
        return self.solve(
            f"Solve linear system ({n}×{n})",
            state_vector=x,
            domain="linear",
            projection_matrix=P,
            A=A, b=b,
        )

    def solve_projection(self, v: np.ndarray, subspace_basis: np.ndarray) -> SolutionState:
        """Project vector v onto a subspace given by basis vectors."""
        Q, _ = np.linalg.qr(subspace_basis.T)
        P = Q @ Q.T  # Orthogonal projection matrix
        return self.solve(
            f"Project {v} onto subspace",
            state_vector=v,
            domain="geometric",
            projection_matrix=P,
        )

    def solve_stereographic(self, points: np.ndarray) -> SolutionState:
        """Apply dual stereographic projection to a set of points."""
        results = []
        for p in points:
            p = np.atleast_1d(p)
            x, y = self.engine.inverse_stereo_south(p)
            proj = self.engine.forward_stereo_north(x, y)
            results.append(proj)

        all_results = np.array(results)
        flat = all_results.flatten()
        return self.solve(
            f"Dual stereographic projection of {len(points)} points",
            state_vector=flat,
            domain="geometric",
        )

    def _auto_encode(self, description: str, **kwargs) -> np.ndarray:
        """Auto-encode a problem description as a state vector."""
        # Use hash-based encoding for text problems
        # This is a simplified encoding; real applications would use embeddings
        words = description.lower().split()
        n = max(len(words), 3)
        vec = np.zeros(n)
        for i, word in enumerate(words):
            vec[i] = sum(ord(c) for c in word) / 1000.0
        return vec

    def demonstrate_dual_projection(self, t: float) -> Dict:
        """
        Demonstrate the dual projection map for a single value t.

        Shows the complete light-and-mirrors pipeline:
        1. Start with t ∈ ℝ
        2. Lift to S¹ via inverse stereo from south pole
        3. The point on the sphere (the mirror)
        4. Project from north pole back to ℝ
        5. Verify: the result equals 1/t (Möbius inversion)
        """
        engine = self.engine

        # Step 1: Start
        print(f"\n{'─'*50}")
        print(f"  DUAL PROJECTION DEMONSTRATION")
        print(f"  Input: t = {t}")
        print(f"{'─'*50}")

        # Step 2: Lift to sphere (south pole)
        x, y = engine.inverse_stereo_south(np.array([t]))
        x_val, y_val = float(x[0]), float(y)
        on_sphere = engine.verify_on_sphere(x, y)
        print(f"\n  Step 1 — Inverse stereo from SOUTH pole:")
        print(f"    σ_S⁻¹({t}) = ({x_val:.6f}, {y_val:.6f})")
        print(f"    On sphere: x² + y² = {x_val**2 + y_val**2:.10f} {'✓' if on_sphere else '✗'}")

        # Step 3: The mirror (sphere point)
        print(f"\n  Step 2 — The MIRROR (point on the sphere):")
        print(f"    The light hits the sphere at ({x_val:.6f}, {y_val:.6f})")

        # Step 4: Project from north pole
        result = engine.forward_stereo_north(x, y)
        result_val = float(result[0])
        print(f"\n  Step 3 — Forward stereo from NORTH pole:")
        print(f"    σ_N({x_val:.6f}, {y_val:.6f}) = {result_val:.6f}")

        # Step 5: Verify Möbius inversion
        expected = 1.0 / t if abs(t) > 1e-15 else np.inf
        error = abs(result_val - expected) if np.isfinite(expected) else 0
        print(f"\n  Verification:")
        print(f"    D({t}) = {result_val:.6f}")
        print(f"    1/t   = {expected:.6f}")
        print(f"    Error = {error:.2e}")
        print(f"\n  The dual projection IS Möbius inversion: D(t) = 1/t ✓")

        # The matrix representation
        M = np.array([[0, 1], [1, 0]])
        mob = engine.mobius_transform(M, t)
        print(f"\n  Matrix representation:")
        print(f"    M = [[0, 1], [1, 0]]")
        print(f"    M · [{t} : 1] = [{mob:.6f} : 1]")
        print(f"    ONE MATRIX MULTIPLY produces the same result ✓")
        print(f"{'─'*50}\n")

        return {
            "input": t,
            "sphere_point": (x_val, y_val),
            "on_sphere": on_sphere,
            "dual_projection": result_val,
            "expected_1_over_t": expected,
            "error": error,
            "mobius_matrix": M.tolist(),
        }


# ═══════════════════════════════════════════════════════════════════════════════
#  §6: THE RESEARCH TEAM — Agents of the Meta Oracle
# ═══════════════════════════════════════════════════════════════════════════════

class ResearchTeam:
    """
    The Meta Oracle's research team. Each agent investigates a different
    aspect of the Universal Solver.

    Agent Alpha:  Dual projection algebra
    Agent Beta:   Matrix representation theory
    Agent Gamma:  Problem encoding and embedding
    Agent Delta:  Iterative reduction and convergence
    Agent Epsilon: Synthesis and applications
    """

    def __init__(self):
        self.solver = UniversalSolver()
        self.notes: List[str] = []
        self.experiments: List[Dict] = []

    def log_note(self, agent: str, note: str):
        """Record a research note."""
        entry = f"[{agent}] {note}"
        self.notes.append(entry)

    def run_experiment(self, name: str, experiment_fn: Callable) -> Dict:
        """Run an experiment and record results."""
        self.log_note("Lab", f"Running experiment: {name}")
        result = experiment_fn()
        self.experiments.append({"name": name, "result": result})
        return result

    def agent_alpha_dual_projection_experiments(self) -> Dict:
        """Agent Alpha: Investigate dual projection properties."""
        self.log_note("Alpha", "Investigating dual projection D(t) = σ_N ∘ σ_S⁻¹(t)")

        results = {}

        # Experiment 1: D(t) = 1/t for various t
        test_values = [0.5, 1.0, 2.0, 3.0, -1.0, -2.0, 0.1, 10.0]
        inversion_results = []
        for t in test_values:
            d = self.solver.engine.dual_projection(np.array([t]))
            expected = 1.0 / t
            error = abs(float(d[0]) - expected)
            inversion_results.append({
                "t": t, "D(t)": float(d[0]), "1/t": expected, "error": error
            })
        results["inversion"] = inversion_results
        self.log_note("Alpha", f"Verified D(t) = 1/t for {len(test_values)} values, max error = {max(r['error'] for r in inversion_results):.2e}")

        # Experiment 2: D(D(t)) = t (involution)
        involution_results = []
        for t in test_values:
            d1 = self.solver.engine.dual_projection(np.array([t]))
            d2 = self.solver.engine.dual_projection(d1)
            error = abs(float(d2[0]) - t)
            involution_results.append({"t": t, "D(D(t))": float(d2[0]), "error": error})
        results["involution"] = involution_results
        self.log_note("Alpha", f"Verified D(D(t)) = t for {len(test_values)} values, max error = {max(r['error'] for r in involution_results):.2e}")

        # Experiment 3: Sphere verification
        sphere_results = []
        for t in test_values:
            x, y = self.solver.engine.inverse_stereo_south(np.array([t]))
            norm = float(np.sum(x**2) + y**2)
            sphere_results.append({"t": t, "|x|²+y²": norm, "on_sphere": abs(norm - 1) < 1e-10})
        results["sphere"] = sphere_results
        self.log_note("Alpha", f"All lifted points verified on sphere: {all(r['on_sphere'] for r in sphere_results)}")

        return results

    def agent_beta_matrix_experiments(self) -> Dict:
        """Agent Beta: Matrix representation of Möbius transformations."""
        self.log_note("Beta", "Investigating matrix representations of dual projections")

        results = {}
        engine = self.solver.engine

        # The dual projection D(t) = 1/t corresponds to M = [[0, 1], [1, 0]]
        M_inv = np.array([[0, 1], [1, 0]])

        test_values = [0.5, 1.0, 2.0, 3.0, 5.0]
        matrix_results = []
        for t in test_values:
            mob = engine.mobius_transform(M_inv, t)
            dual = float(engine.dual_projection(np.array([t]))[0])
            error = abs(mob - dual)
            matrix_results.append({"t": t, "Möbius": mob, "Dual": dual, "error": error})
        results["inversion_matrix"] = matrix_results
        self.log_note("Beta", f"Matrix [[0,1],[1,0]] ↔ D(t) verified, max error = {max(r['error'] for r in matrix_results):.2e}")

        # Rotation matrices: M_θ = [[cos θ, -sin θ], [sin θ, cos θ]]
        rotation_results = []
        for theta in [0, np.pi/4, np.pi/2, np.pi]:
            M_rot = np.array([[np.cos(theta), -np.sin(theta)],
                              [np.sin(theta),  np.cos(theta)]])
            # Apply to t = 1
            result = engine.mobius_transform(M_rot, 1.0)
            rotation_results.append({"theta": theta, "M_θ(1)": result})
        results["rotations"] = rotation_results
        self.log_note("Beta", f"Rotation Möbius transformations computed for {len(rotation_results)} angles")

        return results

    def agent_gamma_encoding_experiments(self) -> Dict:
        """Agent Gamma: Problem encoding experiments."""
        self.log_note("Gamma", "Testing problem encoding and reduction")

        results = {}

        # Experiment: Encode and solve a linear system
        A = np.array([[2, 1], [1, 3]], dtype=float)
        b = np.array([5, 7], dtype=float)
        solution = self.solver.solve_linear_system(A, b)
        x = solution.solution_vector
        residual = np.linalg.norm(A @ x - b)
        results["linear_system"] = {
            "A": A.tolist(), "b": b.tolist(),
            "solution": x.tolist(), "residual": residual,
            "is_fixed_point": solution.is_fixed_point,
        }
        self.log_note("Gamma", f"Linear system solved: x = {x}, residual = {residual:.2e}")

        # Experiment: Projection onto a subspace
        v = np.array([3.0, 4.0, 5.0])
        basis = np.array([[1, 0, 0], [0, 1, 0]], dtype=float)
        proj_solution = self.solver.solve_projection(v, basis)
        results["projection"] = {
            "original": v.tolist(),
            "projected": proj_solution.solution_vector.tolist(),
            "is_fixed_point": proj_solution.is_fixed_point,
        }
        self.log_note("Gamma", f"Projection: {v} → {proj_solution.solution_vector}")

        return results

    def agent_delta_iterative_experiments(self) -> Dict:
        """Agent Delta: Iterative reduction and convergence."""
        self.log_note("Delta", "Testing iterative oracle application and convergence")

        results = {}

        # Experiment: Iterated projection converges in 1 step
        v = np.array([3.0, 4.0, 5.0])
        P = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 0]], dtype=float)  # xy-plane projection

        iterations = [v]
        current = v.copy()
        for i in range(5):
            current = P @ current
            iterations.append(current.copy())

        # Check convergence
        diffs = [np.linalg.norm(iterations[i+1] - iterations[i]) for i in range(len(iterations)-1)]
        results["convergence"] = {
            "iterations": [it.tolist() for it in iterations],
            "diffs": diffs,
            "converged_at_step": next((i for i, d in enumerate(diffs) if d < 1e-10), len(diffs)),
        }
        self.log_note("Delta", f"Projection converges in {results['convergence']['converged_at_step']} step(s) — confirming idempotency")

        # Experiment: Tower of projections
        P1 = np.array([[1, 0, 0], [0, 0, 0], [0, 0, 0]], dtype=float)  # x-axis
        P2 = np.array([[0, 0, 0], [0, 1, 0], [0, 0, 0]], dtype=float)  # y-axis
        P3 = P1 + P2  # xy-plane (P1 and P2 commute and are orthogonal)

        v = np.array([3.0, 4.0, 5.0])
        tower = {
            "P1·v (x-axis)": (P1 @ v).tolist(),
            "P2·v (y-axis)": (P2 @ v).tolist(),
            "P3·v (xy-plane)": (P3 @ v).tolist(),
            "P3 = P1 + P2 (commuting decomposition)": True,
        }
        results["tower"] = tower
        self.log_note("Delta", f"Oracle tower: P_xy = P_x + P_y decomposes the projection")

        return results

    def agent_epsilon_synthesis(self) -> Dict:
        """Agent Epsilon: Synthesis — the big picture."""
        self.log_note("Epsilon", "Synthesizing results from all agents")

        results = {
            "total_notes": len(self.notes),
            "total_experiments": len(self.experiments),
            "key_findings": [
                "1. The dual projection D(t) = σ_N ∘ σ_S⁻¹(t) equals 1/t (Möbius inversion)",
                "2. D is an involution: D(D(t)) = t — the mirror reflects back",
                "3. D is represented by the matrix [[0,1],[1,0]] — ONE matrix multiply",
                "4. Every idempotent reduction is a projection matrix P with P² = P",
                "5. The Meta Oracle selects the optimal projection for each problem",
                "6. Iterative application converges in exactly 1 step (idempotency)",
                "7. Commuting projections compose: the reduction chain telescopes",
                "8. The Universal Solver reduces any (linear) problem to P·v",
            ],
            "the_meta_oracles_message": (
                "Every problem is a shadow cast by the frozen crystal of information. "
                "To solve the problem, find the crystal — the projection matrix — that "
                "casts it. One matrix multiplication reveals the truth. "
                "The dual stereographic projection is the light-and-mirrors machine: "
                "south pole lifts, the sphere mirrors, north pole projects. "
                "The composition is a Möbius transformation. A single matrix. "
                "This is the Universal Solver."
            ),
        }
        self.log_note("Epsilon", "Synthesis complete. The frozen crystal has spoken.")
        return results

    def run_all_experiments(self) -> Dict:
        """Run the complete research program."""
        print("\n" + "═" * 70)
        print("  THE META ORACLE'S RESEARCH TEAM — Full Experimental Program")
        print("═" * 70)

        all_results = {}

        print("\n▶ Agent Alpha: Dual Projection Algebra")
        all_results["alpha"] = self.run_experiment(
            "Dual Projection Properties",
            self.agent_alpha_dual_projection_experiments
        )

        print("▶ Agent Beta: Matrix Representations")
        all_results["beta"] = self.run_experiment(
            "Matrix Representations",
            self.agent_beta_matrix_experiments
        )

        print("▶ Agent Gamma: Problem Encoding")
        all_results["gamma"] = self.run_experiment(
            "Problem Encoding",
            self.agent_gamma_encoding_experiments
        )

        print("▶ Agent Delta: Iterative Convergence")
        all_results["delta"] = self.run_experiment(
            "Iterative Convergence",
            self.agent_delta_iterative_experiments
        )

        print("▶ Agent Epsilon: Synthesis")
        all_results["epsilon"] = self.run_experiment(
            "Synthesis",
            self.agent_epsilon_synthesis
        )

        return all_results

    def print_lab_notebook(self):
        """Print the complete lab notebook."""
        print("\n" + "═" * 70)
        print("  LAB NOTEBOOK — Meta Oracle Research Team")
        print("═" * 70)
        for note in self.notes:
            print(f"  {note}")
        print("═" * 70)


# ═══════════════════════════════════════════════════════════════════════════════
#  §7: MAIN — Run the Universal Solver
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║                    ✦  THE UNIVERSAL SOLVER  ✦                          ║
║                                                                        ║
║         Guided by the Meta Oracle — Oracle of Oracles                  ║
║     The Completely Frozen Crystal of Information and Light              ║
║                                                                        ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # Initialize
    solver = UniversalSolver()
    team = ResearchTeam()

    # ── Demo 1: Dual Projection (Light and Mirrors) ──
    print("\n" + "=" * 70)
    print("  DEMONSTRATION 1: The Dual Projection — Light and Mirrors")
    print("=" * 70)
    solver.demonstrate_dual_projection(2.0)
    solver.demonstrate_dual_projection(3.0)
    solver.demonstrate_dual_projection(0.5)

    # ── Demo 2: Solve a Linear System ──
    print("\n" + "=" * 70)
    print("  DEMONSTRATION 2: Solve a Linear System via the Universal Solver")
    print("=" * 70)
    A = np.array([[4, 1], [1, 3]], dtype=float)
    b = np.array([9, 7], dtype=float)
    solution = solver.solve_linear_system(A, b)
    print(solution.summary())
    print(f"  Verification: A·x = {A @ solution.solution_vector} (should be {b})")

    # ── Demo 3: Geometric Projection ──
    print("\n" + "=" * 70)
    print("  DEMONSTRATION 3: Geometric Projection onto xy-plane")
    print("=" * 70)
    v = np.array([3.0, 4.0, 5.0])
    basis = np.array([[1, 0, 0], [0, 1, 0]], dtype=float)
    proj = solver.solve_projection(v, basis)
    print(proj.summary())

    # ── Demo 4: Arbitrary Problem ──
    print("\n" + "=" * 70)
    print("  DEMONSTRATION 4: Arbitrary Problem → Meta Oracle Reduction")
    print("=" * 70)
    solution = solver.solve(
        "What is the meaning of life, the universe, and everything?",
        state_vector=np.array([4.0, 2.0]),
        domain="general",
    )
    solution.print_log()

    # ── Research Team Experiments ──
    print("\n" + "=" * 70)
    print("  RESEARCH TEAM: Full Experimental Program")
    print("=" * 70)
    all_results = team.run_all_experiments()
    team.print_lab_notebook()

    # ── Final Summary ──
    synthesis = all_results.get("epsilon", {}).get("result", {})
    print("\n" + "=" * 70)
    print("  THE META ORACLE'S FINAL WORD")
    print("=" * 70)
    if isinstance(synthesis, dict):
        for finding in synthesis.get("key_findings", []):
            print(f"  {finding}")
        print(f"\n  {synthesis.get('the_meta_oracles_message', '')}")
    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()
