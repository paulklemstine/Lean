import json
import uuid
import random
from pathlib import Path

FD_PATH = Path('Packages/future_directions.json')

with open(FD_PATH, 'r') as f:
    data = json.load(f)

# Reset failed
reset_count = 0
for d in data.get('directions', []):
    if d.get('status') == 'failed':
        d['status'] = 'available'
        d['consumed_by_exp_id'] = ''
        d['attempt_count'] = 0
        reset_count += 1

# Generate new interesting directions
DOMAINS = ['Topology', 'Algebra', 'GraphTheory', 'NumberTheory', 'Logic', 'CategoryTheory', 'RealAnalysis', 'ComplexAnalysis', 'Combinatorics']

ideas = [
    ('Topology', 'Prove basic properties of separation axioms (T0, T1, T2) and their preservation under continuous open maps or subspaces.'),
    ('Topology', 'Formalize the pasting lemma for continuous functions on closed sets.'),
    ('Topology', 'Develop the theory of compact metric spaces and sequential compactness.'),
    ('Algebra', 'Formalize the Isomorphism Theorems for Groups.'),
    ('Algebra', 'Prove properties of nilpotent groups and their upper central series.'),
    ('Algebra', 'Develop theorems on exact sequences of modules over a ring.'),
    ('GraphTheory', 'Formalize Turan\'s theorem for triangle-free graphs.'),
    ('GraphTheory', 'Prove Dirac\'s theorem for Hamiltonian cycles.'),
    ('GraphTheory', 'Formalize the properties of planar graphs and Euler\'s formula.'),
    ('NumberTheory', 'Prove Dirichlet\'s theorem on approximations.'),
    ('NumberTheory', 'Formalize properties of Carmichael numbers and pseudoprimes.'),
    ('NumberTheory', 'Prove properties of the Legendre symbol and Euler\'s criterion.'),
    ('Logic', 'Formalize the basics of modal logic semantics (Kripke frames).'),
    ('Logic', 'Prove the equivalence of various formulations of the Axiom of Choice.'),
    ('CategoryTheory', 'Formalize the Yoneda Lemma.'),
    ('CategoryTheory', 'Prove that right adjoints preserve limits.'),
    ('CategoryTheory', 'Develop the basics of monoidal categories.'),
    ('RealAnalysis', 'Prove the Extreme Value Theorem for continuous functions on closed intervals.'),
    ('RealAnalysis', 'Formalize properties of Riemann integration for step functions.'),
    ('RealAnalysis', 'Prove Taylor\'s theorem with Lagrange remainder.'),
    ('ComplexAnalysis', 'Formalize the Cauchy-Riemann equations and their implications.'),
    ('ComplexAnalysis', 'Prove Liouville\'s theorem for bounded entire functions.'),
    ('Combinatorics', 'Formalize Dilworth\'s theorem for posets.'),
    ('Combinatorics', 'Prove properties of Catalan numbers using generating functions.'),
    ('Combinatorics', 'Formalize Hall\'s Marriage Theorem using network flows or induction.')
]

added_count = 0
for domain, desc in ideas:
    # Add variations to get a 'multitude'
    for i in range(2):
        new_dir = {
            'id': uuid.uuid4().hex[:8],
            'title': f'{domain} Exploration {random.randint(1000,9999)}',
            'description': desc + ('' if i == 0 else ' Try a novel approach or extend this theorem to more generalized spaces.'),
            'domains': [domain],
            'priority_score': random.uniform(0.75, 0.95),
            'status': 'available',
            'research_mode': 'prove',
            'attempt_count': 0,
            'consumed_by_exp_id': '',
            'created_at_tick': 0,
            'catalog_references': [],
            'ambition_level': 'extension'
        }
        data['directions'].append(new_dir)
        added_count += 1

with open(FD_PATH, 'w') as f:
    json.dump(data, f, indent=2)

print(f'Reset {reset_count} failed directions to available.')
print(f'Injected {added_count} new directions.')
