#!/usr/bin/env python3
"""
Algorithms for Polynomial Interpolation and Reed-Solomon Codes

Implements the core algorithms underlying the certified linear equivalence
between bounded-degree polynomials and function values:
  - Lagrange interpolation (O(n²) and barycentric O(n) evaluation)
  - Vandermonde system solving
  - Reed-Solomon encoding/decoding
  - Newton's divided differences
"""

from typing import List, Tuple, Optional
import numpy as np


class LagrangeInterpolator:
    """
    Lagrange polynomial interpolation with barycentric weights.
    
    Given n+1 distinct nodes x_0, ..., x_n and values y_0, ..., y_n,
    constructs the unique polynomial p of degree ≤ n such that p(x_i) = y_i.
    
    Time complexity:
      - Preprocessing (weights): O(n²)
      - Single evaluation: O(n) via barycentric formula
      - Coefficient extraction: O(n²)
    
    Space complexity: O(n)
    """
    
    def __init__(self, nodes: np.ndarray, values: np.ndarray):
        """
        Initialize the interpolator.
        
        Args:
            nodes: Array of n+1 distinct interpolation nodes.
            values: Array of n+1 function values at the nodes.
            
        Raises:
            ValueError: If nodes are not distinct or arrays have different lengths.
        """
        if len(nodes) != len(values):
            raise ValueError("nodes and values must have the same length")
        if len(set(nodes)) != len(nodes):
            raise ValueError("nodes must be distinct")
        
        self.nodes = np.array(nodes, dtype=float)
        self.values = np.array(values, dtype=float)
        self.n = len(nodes) - 1  # degree bound
        self._weights = self._compute_barycentric_weights()
    
    def _compute_barycentric_weights(self) -> np.ndarray:
        """Compute barycentric weights w_i = 1 / prod_{j≠i} (x_i - x_j)."""
        n = len(self.nodes)
        weights = np.ones(n)
        for i in range(n):
            for j in range(n):
                if i != j:
                    weights[i] /= (self.nodes[i] - self.nodes[j])
        return weights
    
    def evaluate(self, x: float) -> float:
        """
        Evaluate the interpolating polynomial at x using the barycentric formula.
        
        The barycentric formula of the second kind:
            p(x) = [sum_i w_i * y_i / (x - x_i)] / [sum_i w_i / (x - x_i)]
        
        Time: O(n)
        """
        # Check if x is a node
        for i, xi in enumerate(self.nodes):
            if abs(x - xi) < 1e-15:
                return self.values[i]
        
        terms = self._weights / (x - self.nodes)
        return np.dot(terms, self.values) / np.sum(terms)
    
    def coefficients(self) -> np.ndarray:
        """
        Extract the coefficient vector [a_0, a_1, ..., a_n] of the interpolant.
        
        Uses the explicit Lagrange basis polynomial construction.
        Time: O(n²)
        """
        n = len(self.nodes)
        result = np.zeros(n)
        for i in range(n):
            basis = np.array([1.0])
            for j in range(n):
                if j != i:
                    factor = np.array([-self.nodes[j], 1.0]) / (self.nodes[i] - self.nodes[j])
                    basis = np.convolve(basis, factor)
            result += self.values[i] * basis
        return result
    
    def update_value(self, index: int, new_value: float) -> None:
        """
        Update a single function value. The linearity of the interpolation map
        means only the values array needs updating; weights are node-dependent only.
        
        Time: O(1) for update, O(n) for next evaluation
        """
        self.values[index] = new_value


class NewtonInterpolator:
    """
    Newton's divided difference interpolation.
    
    Represents the interpolant in the Newton form:
        p(x) = c_0 + c_1(x-x_0) + c_2(x-x_0)(x-x_1) + ...
    
    Advantages over Lagrange form:
      - Adding a new node costs O(n) instead of O(n²)
      - Evaluation via Horner's method is numerically stable
    
    Time complexity:
      - Construction: O(n²)
      - Evaluation: O(n)
      - Adding a point: O(n)
    """
    
    def __init__(self, nodes: np.ndarray, values: np.ndarray):
        self.nodes = list(nodes)
        self.values = list(values)
        self.divided_diffs = self._compute_divided_differences()
    
    def _compute_divided_differences(self) -> List[float]:
        """Compute the divided difference table."""
        n = len(self.nodes)
        dd = list(self.values)
        for j in range(1, n):
            for i in range(n - 1, j - 1, -1):
                dd[i] = (dd[i] - dd[i - 1]) / (self.nodes[i] - self.nodes[i - j])
        return dd
    
    def evaluate(self, x: float) -> float:
        """Evaluate using Horner's method on the Newton form."""
        n = len(self.nodes)
        result = self.divided_diffs[n - 1]
        for i in range(n - 2, -1, -1):
            result = result * (x - self.nodes[i]) + self.divided_diffs[i]
        return result
    
    def add_point(self, x: float, y: float) -> None:
        """Add a new interpolation point in O(n) time."""
        self.nodes.append(x)
        self.values.append(y)
        # Compute new divided difference
        n = len(self.nodes) - 1
        new_dd = y
        for j in range(n):
            new_dd = (new_dd - self.divided_diffs[j])
            denom = x - self.nodes[j]
            new_dd /= denom
        self.divided_diffs.append(new_dd)


class VandermondeSystem:
    """
    Solve the Vandermonde system V · c = y for interpolation coefficients.
    
    The Vandermonde matrix V[i,j] = x_i^j is invertible iff nodes are distinct.
    This class demonstrates the connection between interpolation and linear algebra.
    
    Time: O(n³) via direct inversion (use Lagrange for O(n²) in practice)
    """
    
    def __init__(self, nodes: np.ndarray):
        self.nodes = np.array(nodes, dtype=float)
        self.n = len(nodes)
        self.V = self._build_vandermonde()
    
    def _build_vandermonde(self) -> np.ndarray:
        """Build the Vandermonde matrix."""
        V = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                V[i, j] = self.nodes[i] ** j
        return V
    
    def solve(self, values: np.ndarray) -> np.ndarray:
        """Solve V·c = values for the coefficient vector c."""
        return np.linalg.solve(self.V, values)
    
    def determinant(self) -> float:
        """
        Compute det(V) = prod_{i<j} (x_j - x_i).
        
        The Vandermonde determinant formula proves that V is invertible
        iff all nodes are distinct.
        """
        det = 1.0
        for i in range(self.n):
            for j in range(i + 1, self.n):
                det *= (self.nodes[j] - self.nodes[i])
        return det
    
    def condition_number(self) -> float:
        """Compute the condition number of V (2-norm)."""
        return np.linalg.cond(self.V)


class ReedSolomonCode:
    """
    Reed-Solomon error-correcting code based on polynomial evaluation.
    
    An [n, k, n-k+1] Reed-Solomon code:
      - Message: k symbols (coefficients of degree ≤ k-1 polynomial)
      - Codeword: n symbols (evaluations at n distinct points)
      - Minimum distance: d = n - k + 1
      - Can correct: ⌊(d-1)/2⌋ errors or d-1 erasures
    
    The linear equivalence theorem guarantees exact encoding/decoding:
      evaluation (encoding) and interpolation (decoding) are inverse linear maps.
    """
    
    def __init__(self, eval_points: np.ndarray, message_length: int):
        """
        Args:
            eval_points: n distinct evaluation points.
            message_length: k, the message dimension (degree bound + 1).
        """
        self.eval_points = np.array(eval_points, dtype=float)
        self.n = len(eval_points)
        self.k = message_length
        self.d = self.n - self.k + 1  # minimum distance
        
        if self.k > self.n:
            raise ValueError("message_length must be ≤ number of eval points")
        if len(set(eval_points)) != self.n:
            raise ValueError("evaluation points must be distinct")
    
    def encode(self, message: np.ndarray) -> np.ndarray:
        """
        Encode a message (polynomial coefficients) to a codeword (evaluations).
        
        This is the forward direction of the linear equivalence.
        Time: O(n·k)
        """
        if len(message) != self.k:
            raise ValueError(f"Message must have {self.k} symbols")
        
        codeword = np.zeros(self.n)
        for i, x in enumerate(self.eval_points):
            codeword[i] = sum(message[j] * x**j for j in range(self.k))
        return codeword
    
    def decode_erasures(self, received: np.ndarray,
                        received_positions: List[int]) -> np.ndarray:
        """
        Decode from received symbols at known positions (erasure decoding).
        
        Requires at least k received symbols. Uses the inverse direction
        of the linear equivalence (Lagrange interpolation).
        
        Args:
            received: Values at the received positions.
            received_positions: Indices into eval_points where values were received.
            
        Returns:
            Decoded message (polynomial coefficients).
        """
        if len(received) < self.k:
            raise ValueError(f"Need at least {self.k} received symbols")
        
        # Use any k of the received positions
        use = received_positions[:self.k]
        use_nodes = self.eval_points[use]
        use_values = received[:self.k]
        
        interp = LagrangeInterpolator(use_nodes, use_values)
        coeffs = interp.coefficients()
        return coeffs[:self.k]
    
    def generator_matrix(self) -> np.ndarray:
        """
        The generator matrix G[i,j] = eval_points[i]^j.
        
        Encoding is matrix-vector multiplication: c = G · m.
        This is the matrix representation of the evaluation linear map.
        """
        G = np.zeros((self.n, self.k))
        for i in range(self.n):
            for j in range(self.k):
                G[i, j] = self.eval_points[i] ** j
        return G
    
    def parameters(self) -> dict:
        """Return code parameters."""
        return {
            "n": self.n,
            "k": self.k,
            "d": self.d,
            "rate": self.k / self.n,
            "max_errors": (self.d - 1) // 2,
            "max_erasures": self.d - 1,
        }


def demo_algorithms():
    """Run demonstrations of all algorithms."""
    print("Lagrange Interpolation")
    print("-" * 40)
    nodes = np.array([0.0, 1.0, 2.0, 3.0])
    values = np.array([1.0, 0.0, 1.0, 10.0])
    
    interp = LagrangeInterpolator(nodes, values)
    print(f"Nodes: {nodes}")
    print(f"Values: {values}")
    print(f"Coefficients: {np.round(interp.coefficients(), 8)}")
    print(f"p(1.5) = {interp.evaluate(1.5):.6f}")
    
    print("\nNewton Interpolation")
    print("-" * 40)
    newton = NewtonInterpolator(nodes, values)
    print(f"Divided differences: {[round(d, 8) for d in newton.divided_diffs]}")
    print(f"p(1.5) = {newton.evaluate(1.5):.6f}")
    
    # Add a point
    newton.add_point(4.0, 29.0)
    print(f"After adding (4, 29): p(1.5) = {newton.evaluate(1.5):.6f}")
    
    print("\nVandermonde System")
    print("-" * 40)
    vs = VandermondeSystem(nodes)
    print(f"Vandermonde det = {vs.determinant():.4f}")
    print(f"Condition number = {vs.condition_number():.4f}")
    coeffs = vs.solve(values)
    print(f"Solved coefficients: {np.round(coeffs, 8)}")
    
    print("\nReed-Solomon Code")
    print("-" * 40)
    rs = ReedSolomonCode(np.array([1, 2, 3, 4, 5, 6, 7], dtype=float), 4)
    params = rs.parameters()
    print(f"Parameters: [{params['n']}, {params['k']}, {params['d']}]")
    print(f"Rate: {params['rate']:.3f}")
    print(f"Max errors: {params['max_errors']}, Max erasures: {params['max_erasures']}")
    
    msg = np.array([3.0, 1.0, 4.0, 1.0])
    codeword = rs.encode(msg)
    print(f"Message: {msg}")
    print(f"Codeword: {codeword}")
    
    # Simulate erasures
    received = codeword[[0, 2, 3, 5]]
    decoded = rs.decode_erasures(received, [0, 2, 3, 5])
    print(f"Decoded (from 4 of 7): {np.round(decoded, 8)}")
    print(f"Correct: {np.allclose(decoded, msg)}")


if __name__ == "__main__":
    demo_algorithms()
