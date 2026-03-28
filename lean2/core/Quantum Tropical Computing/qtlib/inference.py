"""
Tropical Inference Engines
============================

Implements inference algorithms using tropical (max-plus) algebra:

    - TropicalViterbi: Most likely sequence decoding (HMM Viterbi = tropical matrix power)
    - TropicalBayesNet: Tropical belief propagation (MAP inference)
    - TropicalBeliefPropagation: Message passing in tropical factor graphs
    - tropical_infer: High-level inference API

Key insight: MAP (Maximum A Posteriori) inference is EXACTLY tropical linear algebra.
    - Log-probabilities live in the tropical semiring
    - Marginalization via max (not sum) is tropical addition
    - Conditioning via addition of log-priors is tropical multiplication
    - The Viterbi algorithm IS tropical matrix-vector multiplication
"""

import numpy as np
from typing import List, Dict, Optional, Tuple
from qtlib.semiring import TROP_NEG_INF, trop_matvec, trop_matmul


class TropicalViterbi:
    """Viterbi decoding as tropical matrix power.

    For an HMM with:
        - Transition matrix A (log-probabilities): A_{ij} = log P(s_t=j | s_{t-1}=i)
        - Emission matrix B (log-probabilities): B_{ij} = log P(o_t=j | s_t=i)
        - Initial distribution π (log-probabilities): π_i = log P(s_0=i)

    The Viterbi algorithm computes:
        δ_t = A^T ⊗ (δ_{t-1} + b_t)

    where ⊗ is tropical matrix-vector multiplication and b_t is the emission
    column for observation o_t.

    This is tropical linear algebra applied to sequence decoding.
    """

    def __init__(self, n_states: int, n_observations: int):
        self.n_states = n_states
        self.n_obs = n_observations

        # Initialize with uniform log-probabilities
        self.log_transition = np.full((n_states, n_states), -np.log(n_states))
        self.log_emission = np.full((n_states, n_observations), -np.log(n_observations))
        self.log_initial = np.full(n_states, -np.log(n_states))

    def set_parameters(self, transition: np.ndarray, emission: np.ndarray,
                       initial: np.ndarray):
        """Set HMM parameters (as log-probabilities)."""
        self.log_transition = np.asarray(transition, dtype=float)
        self.log_emission = np.asarray(emission, dtype=float)
        self.log_initial = np.asarray(initial, dtype=float)

    def decode(self, observations: List[int]) -> dict:
        """Decode the most likely state sequence (Viterbi algorithm).

        This IS tropical linear algebra:
            δ_t(j) = max_i [δ_{t-1}(i) + A_{ij}] + B_{j, o_t}
                    = (A^T ⊗_T δ_{t-1})_j + B_{j, o_t}

        Parameters
        ----------
        observations : list of int
            Sequence of observation indices

        Returns
        -------
        dict with:
            'states': most likely state sequence
            'log_probability': log-probability of the best path
            'trellis': the δ matrix (tropical computation trace)
        """
        T = len(observations)
        n = self.n_states

        # Trellis (tropical computation trace)
        delta = np.full((T, n), TROP_NEG_INF)
        psi = np.zeros((T, n), dtype=int)

        # Initialization: δ_0(i) = π_i + B_{i, o_0}
        delta[0] = self.log_initial + self.log_emission[:, observations[0]]

        # Recursion: tropical matrix-vector product
        for t in range(1, T):
            for j in range(n):
                # δ_t(j) = max_i [δ_{t-1}(i) + A_{ij}] + B_{j, o_t}
                scores = delta[t-1] + self.log_transition[:, j]
                psi[t, j] = np.argmax(scores)
                delta[t, j] = scores[psi[t, j]] + self.log_emission[j, observations[t]]

        # Backtracking
        states = np.zeros(T, dtype=int)
        states[-1] = np.argmax(delta[-1])
        for t in range(T-2, -1, -1):
            states[t] = psi[t+1, states[t+1]]

        return {
            'states': states.tolist(),
            'log_probability': float(np.max(delta[-1])),
            'trellis': delta,
        }


class TropicalBayesNet:
    """Tropical Bayesian Network for MAP inference.

    A Bayesian network where all computations use tropical (max-plus) arithmetic:
        - Node potentials are log-probabilities
        - Message passing uses tropical matrix-vector products
        - Inference finds the MAP (most probable) assignment

    Structure: a DAG where each node has:
        - A set of parents
        - A conditional probability table (as log-probabilities)
    """

    def __init__(self):
        self.nodes: Dict[str, dict] = {}
        self.edges: List[Tuple[str, str]] = []

    def add_node(self, name: str, values: int, parents: List[str] = None,
                 log_cpt: np.ndarray = None):
        """Add a node to the network.

        Parameters
        ----------
        name : str
        values : int
            Number of possible values
        parents : list of str
        log_cpt : array
            Log conditional probability table.
            Shape: (|parent_1| × ... × |parent_k|, values) or (values,) for roots.
        """
        parents = parents or []
        if log_cpt is None:
            log_cpt = np.full(values, -np.log(values))  # uniform

        self.nodes[name] = {
            'values': values,
            'parents': parents,
            'log_cpt': log_cpt,
        }

        for parent in parents:
            self.edges.append((parent, name))

    def infer_map(self, evidence: Dict[str, int] = None) -> dict:
        """Find the MAP (most probable) assignment.

        Uses tropical message passing (variable elimination with max).

        Parameters
        ----------
        evidence : dict mapping node names to observed values

        Returns
        -------
        dict with:
            'assignment': MAP assignment {node: value}
            'log_probability': log-probability of MAP assignment
        """
        evidence = evidence or {}
        assignment = {}
        log_prob = 0.0

        # Topological sort
        order = self._topological_sort()

        # Forward pass: compute tropical messages
        messages = {}
        for node_name in order:
            node = self.nodes[node_name]

            if node_name in evidence:
                # Observed: set to evidence value
                assignment[node_name] = evidence[node_name]
                msg = np.full(node['values'], TROP_NEG_INF)
                msg[evidence[node_name]] = 0.0
                messages[node_name] = msg
            else:
                # Unobserved: compute tropical message from parents
                if not node['parents']:
                    # Root node
                    messages[node_name] = node['log_cpt'].copy()
                else:
                    # Compute max over parent configurations
                    log_cpt = node['log_cpt']
                    if log_cpt.ndim == 1:
                        messages[node_name] = log_cpt.copy()
                    else:
                        # For each value of this node, find best parent config
                        parent_msgs = [messages[p] for p in node['parents']]
                        msg = np.full(node['values'], TROP_NEG_INF)
                        # Iterate over parent configurations
                        parent_sizes = [self.nodes[p]['values'] for p in node['parents']]
                        for v in range(node['values']):
                            best = TROP_NEG_INF
                            for idx in np.ndindex(*parent_sizes):
                                score = log_cpt[idx + (v,)]
                                for k, p in enumerate(node['parents']):
                                    score += parent_msgs[k][idx[k]]
                                best = max(best, score)
                            msg[v] = best
                        messages[node_name] = msg

        # Extract MAP assignment
        for node_name in order:
            if node_name not in evidence:
                assignment[node_name] = int(np.argmax(messages[node_name]))
                log_prob += messages[node_name][assignment[node_name]]

        return {
            'assignment': assignment,
            'log_probability': log_prob,
        }

    def _topological_sort(self) -> List[str]:
        """Topological sort of the DAG."""
        in_degree = {name: 0 for name in self.nodes}
        for parent, child in self.edges:
            in_degree[child] += 1

        queue = [n for n in self.nodes if in_degree[n] == 0]
        order = []
        while queue:
            node = queue.pop(0)
            order.append(node)
            for parent, child in self.edges:
                if parent == node:
                    in_degree[child] -= 1
                    if in_degree[child] == 0:
                        queue.append(child)
        return order


class TropicalBeliefPropagation:
    """Tropical belief propagation on factor graphs.

    Messages are log-domain values, and "summation" is replaced by max
    (tropical addition). This computes MAP inference rather than
    marginal inference.

    Equivalent to the max-product algorithm / min-sum algorithm.
    """

    def __init__(self, n_variables: int, domains: List[int]):
        self.n_vars = n_variables
        self.domains = domains
        self.factors: List[dict] = []
        self.messages: Dict = {}

    def add_factor(self, variables: List[int], log_potential: np.ndarray):
        """Add a factor (log-potential function) to the graph.

        Parameters
        ----------
        variables : list of variable indices
        log_potential : array indexed by variable values
        """
        self.factors.append({
            'variables': variables,
            'log_potential': log_potential,
        })

    def run(self, n_iterations: int = 10) -> dict:
        """Run tropical belief propagation.

        Returns
        -------
        dict with:
            'beliefs': list of arrays (tropical beliefs for each variable)
            'assignment': MAP assignment
        """
        # Initialize messages to zero (tropical multiplicative identity)
        for factor_idx, factor in enumerate(self.factors):
            for var in factor['variables']:
                key_fv = (f'f{factor_idx}', f'v{var}')
                key_vf = (f'v{var}', f'f{factor_idx}')
                self.messages[key_fv] = np.zeros(self.domains[var])
                self.messages[key_vf] = np.zeros(self.domains[var])

        # Iterative message passing
        for iteration in range(n_iterations):
            # Variable → Factor messages
            for factor_idx, factor in enumerate(self.factors):
                for var in factor['variables']:
                    msg = np.zeros(self.domains[var])
                    # Sum (tropical = max) of all incoming factor messages except this one
                    for other_idx, other_factor in enumerate(self.factors):
                        if other_idx != factor_idx and var in other_factor['variables']:
                            key = (f'f{other_idx}', f'v{var}')
                            msg += self.messages.get(key, np.zeros(self.domains[var]))
                    self.messages[(f'v{var}', f'f{factor_idx}')] = msg

            # Factor → Variable messages
            for factor_idx, factor in enumerate(self.factors):
                for var in factor['variables']:
                    other_vars = [v for v in factor['variables'] if v != var]
                    msg = np.full(self.domains[var], TROP_NEG_INF)

                    # Max over other variables (tropical marginalization)
                    if not other_vars:
                        msg = factor['log_potential'].copy()
                    else:
                        for val in range(self.domains[var]):
                            best = TROP_NEG_INF
                            # Iterate over configurations of other variables
                            other_domains = [self.domains[v] for v in other_vars]
                            for idx in np.ndindex(*other_domains):
                                # Build full index
                                full_idx = []
                                other_pos = 0
                                for v in factor['variables']:
                                    if v == var:
                                        full_idx.append(val)
                                    else:
                                        full_idx.append(idx[other_pos])
                                        other_pos += 1
                                score = factor['log_potential'][tuple(full_idx)]
                                # Add incoming messages from other variables
                                for k, v in enumerate(other_vars):
                                    key = (f'v{v}', f'f{factor_idx}')
                                    score += self.messages[key][idx[k]]
                                best = max(best, score)
                            msg[val] = best

                    self.messages[(f'f{factor_idx}', f'v{var}')] = msg

        # Compute beliefs
        beliefs = []
        assignment = []
        for var in range(self.n_vars):
            belief = np.zeros(self.domains[var])
            for factor_idx, factor in enumerate(self.factors):
                if var in factor['variables']:
                    key = (f'f{factor_idx}', f'v{var}')
                    belief += self.messages.get(key, np.zeros(self.domains[var]))
            beliefs.append(belief)
            assignment.append(int(np.argmax(belief)))

        return {
            'beliefs': beliefs,
            'assignment': assignment,
        }


def tropical_infer(model_type: str = 'viterbi', **kwargs) -> dict:
    """High-level tropical inference API.

    Parameters
    ----------
    model_type : str
        One of 'viterbi', 'bayesnet', 'bp'
    **kwargs : model-specific parameters

    Returns
    -------
    Inference results (model-specific dict)
    """
    if model_type == 'viterbi':
        n_states = kwargs.get('n_states', 3)
        n_obs = kwargs.get('n_observations', 4)
        viterbi = TropicalViterbi(n_states, n_obs)
        if 'transition' in kwargs:
            viterbi.set_parameters(
                kwargs['transition'], kwargs['emission'], kwargs['initial']
            )
        return viterbi.decode(kwargs.get('observations', [0, 1, 2, 1]))

    elif model_type == 'bayesnet':
        net = kwargs.get('network')
        if net is None:
            raise ValueError("Provide 'network' parameter (TropicalBayesNet)")
        return net.infer_map(kwargs.get('evidence'))

    elif model_type == 'bp':
        bp = kwargs.get('bp_model')
        if bp is None:
            raise ValueError("Provide 'bp_model' parameter (TropicalBeliefPropagation)")
        return bp.run(kwargs.get('n_iterations', 10))

    else:
        raise ValueError(f"Unknown model type: {model_type}")
