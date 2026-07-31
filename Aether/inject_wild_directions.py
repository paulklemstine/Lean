import json
import uuid
import random
from pathlib import Path

FD_PATH = Path('Packages/future_directions.json')

with open(FD_PATH, 'r') as f:
    data = json.load(f)

DOMAINS = ['Topology', 'Algebra', 'GraphTheory', 'NumberTheory', 'Logic', 'CategoryTheory', 'RealAnalysis', 'ComplexAnalysis', 'Combinatorics', 'SetTheory', 'Geometry']

wild_ideas = [
    ('Logic', 'Formalize a multi-valued logic system where the truth values themselves form a non-Abelian group, and prove its soundness.'),
    ('Topology', 'Explore the topological properties of spaces with a fractional dimension defined via pathological open sets, such as a topology based on the Cantor set\'s complement.'),
    ('Algebra', 'Construct an algebraic structure where addition and multiplication are non-associative, chaotic operators inspired by strange attractors, and prove its fundamental theorem.'),
    ('Combinatorics', 'Formalize Ramsey theory on infinite graphs where edge colors are drawn from an uncountable set, exploring bounds on monochromatic subgraphs.'),
    ('NumberTheory', 'Investigate the properties of quantum integers—a semi-ring where prime factorization is superposed, and prove an analogue of the Fundamental Theorem of Arithmetic.'),
    ('Geometry', 'Formalize properties of hyperbolic geometries where the curvature fluctuates stochastically based on a random variable, proving expected area bounds.'),
    ('CategoryTheory', 'Construct an infinite-dimensional category where the morphisms between morphisms are given by the braid group, and prove its coherence conditions.'),
    ('GraphTheory', 'Explore graphs where edges exist in a state of quantum superposition, and prove the expected value of the chromatic number under measurement.'),
    ('SetTheory', 'Formalize a version of Set Theory where the Axiom of Choice is replaced by the Axiom of Determinacy, and prove properties of infinite games.'),
    ('NumberTheory', 'Prove theorems about alien primes, numbers that are prime in base 10 but composite in a non-integer base like the golden ratio.'),
    ('Algebra', 'Explore the representation theory of groups acting on fractal spaces, proving irreducible character relations.'),
    ('Topology', 'Formalize the concept of a Möbius manifold where local neighborhoods are non-orientable in 4 dimensions.'),
    ('Logic', 'Develop a formal proof system for paradoxes, exploring consistent theories of inconsistent axioms using paraconsistent logic.'),
    ('RealAnalysis', 'Define and prove properties of non-Newtonian calculus where the derivative operator is non-linear and based on geometric means.'),
    ('ComplexAnalysis', 'Investigate analytic continuation over fractal boundaries that are everywhere non-differentiable.'),
    ('GraphTheory', 'Prove the existence of hypergraphs that cannot be embedded in any finite-dimensional Euclidean space but can be embedded in a finite-dimensional p-adic space.'),
    ('Algebra', 'Formalize algebraic structures over the surreal numbers and prove a generalized Cayley-Hamilton theorem for them.'),
    ('Geometry', 'Explore non-Euclidean spaces where the triangle inequality is fundamentally reversed.'),
    ('CategoryTheory', 'Formalize the theory of fuzzy categories where morphisms exist with a probability p, and define functors between them.'),
    ('Combinatorics', 'Investigate combinatorial games played on non-orientable surfaces and prove winning strategies for them.')
]

added_count = 0
for domain, desc in wild_ideas:
    for i in range(5):
        new_dir = {
            'id': uuid.uuid4().hex[:8],
            'title': f'{domain} Wild Speculation {random.randint(1000,9999)}',
            'description': desc + (' Also consider the boundary cases where standard intuition completely breaks down.' if i % 2 == 0 else ''),
            'domains': [domain],
            'priority_score': random.uniform(0.90, 1.0),
            'status': 'available',
            'research_mode': 'prove',
            'attempt_count': 0,
            'consumed_by_exp_id': '',
            'created_at_tick': 0,
            'catalog_references': [],
            'ambition_level': 'breakthrough'
        }
        data['directions'].append(new_dir)
        added_count += 1

with open(FD_PATH, 'w') as f:
    json.dump(data, f, indent=2)

print(f'Injected {added_count} bizarre and wild directions.')
