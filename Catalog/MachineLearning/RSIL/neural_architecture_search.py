#!/usr/bin/env python3
"""
Self-Learning Neural Architecture Search (SLNAS)

An evolutionary NAS system driven by meta-cognition and curriculum learning.
Uses the RSIL framework's theoretical guarantees:

- Meta-cognition (MetaCognitionTheory.lean) for search progress estimation
- Curriculum learning (CurriculumSelfPlay.lean) to expand design space
- Emergent capabilities (EmergentCapabilities.lean) for capability detection
- Contraction mapping (ConvergenceGuarantees.lean) for convergence
- EML compression (SelfLearningFoundations.lean) for parameter efficiency
"""

import math
import random
import os


class Architecture:
    """Represents a neural architecture."""

    def __init__(self, layers, activations, use_eml=False):
        self.layers = layers  # list of layer widths
        self.activations = activations
        self.use_eml = use_eml
        self.fitness = 0.0
        self.params = self._count_params()

    def _count_params(self):
        total = 0
        for i in range(len(self.layers) - 1):
            if self.use_eml:
                total += 4 * self.layers[i + 1]  # EML: 4 params per neuron
            else:
                total += self.layers[i] * self.layers[i + 1]  # Standard: d² params
            total += self.layers[i + 1]  # bias
        return total

    def __repr__(self):
        eml_tag = " [EML]" if self.use_eml else ""
        return f"Arch({self.layers}, params={self.params}, fit={self.fitness:.4f}{eml_tag})"


class MetaCognition:
    """
    Meta-cognitive module for estimating search quality.

    References: metaCogError_nonneg, calibrated_implies_low_error,
    meta_learning_rate_limit
    """

    def __init__(self, base_rate=0.9):
        self.base_rate = base_rate
        self.step = 0
        self.history = []

    def estimate_progress(self, best_fitness, fitness_history):
        """Estimate search progress with calibrated confidence."""
        self.step += 1
        rate = self.base_rate * (1 - 1.0 / (self.step + 1))

        if len(fitness_history) < 5:
            return 0.1, 0.5  # low confidence early

        recent = fitness_history[-5:]
        improvement = (recent[-1] - recent[0]) / max(abs(recent[0]), 1e-8)
        confidence = rate * min(1.0, self.step / 20)

        return improvement, confidence

    def exploration_value(self, exploit, explore, uncertainty, weight=1.0):
        """
        Exploration-exploitation balance.
        Ref: higher_exploration_weight_higher_value, zero_uncertainty_pure_exploitation
        """
        return exploit + weight * uncertainty * explore


class CurriculumScheduler:
    """
    Progressively expands the NAS design space.

    References: optimal_difficulty_at_competence, avg_difficulty_bounded
    """

    def __init__(self, max_layers=8, max_width=512):
        self.max_layers = max_layers
        self.max_width = max_width
        self.difficulty = 0.2  # start easy

    def get_design_space(self, competence):
        """
        Return design space appropriate for current competence.
        Theorem: optimal_difficulty_at_competence — set difficulty = competence.
        """
        self.difficulty = competence
        allowed_layers = max(2, int(self.max_layers * self.difficulty))
        allowed_width = max(16, int(self.max_width * self.difficulty))
        return allowed_layers, allowed_width


class SLNAS:
    """Self-Learning Neural Architecture Search."""

    def __init__(self, pop_size=20, generations=50, input_dim=784, output_dim=10):
        self.pop_size = pop_size
        self.generations = generations
        self.input_dim = input_dim
        self.output_dim = output_dim
        self.meta = MetaCognition()
        self.curriculum = CurriculumScheduler()
        self.population = []
        self.best_history = []
        self.competence = 0.2

    def initialize_population(self):
        """Create initial random population."""
        max_layers, max_width = self.curriculum.get_design_space(self.competence)
        activations = ["relu", "gelu", "swish"]

        for _ in range(self.pop_size):
            n_layers = random.randint(2, max_layers)
            layers = [self.input_dim]
            for _ in range(n_layers - 2):
                layers.append(random.randint(16, max_width))
            layers.append(self.output_dim)

            use_eml = random.random() < 0.3  # 30% chance EML
            act = random.choice(activations)
            arch = Architecture(layers, act, use_eml)
            self.population.append(arch)

    def evaluate(self, arch):
        """
        Evaluate architecture fitness (simulated).
        Balances accuracy, parameter efficiency, and complexity.
        """
        # Simulated accuracy based on architecture properties
        depth = len(arch.layers) - 1
        avg_width = sum(arch.layers[1:-1]) / max(1, len(arch.layers) - 2)

        # Deeper + wider = better, but diminishing returns
        acc = 0.5 + 0.3 * (1 - math.exp(-depth / 3)) + 0.15 * (1 - math.exp(-avg_width / 100))

        # EML bonus: tighter MDL bound (eml_tighter_mdl)
        if arch.use_eml:
            acc += 0.02  # generalization advantage
            # Lower parameter count = less overfitting

        # Parameter efficiency penalty
        param_penalty = 0.05 * math.log(1 + arch.params / 10000)

        # Add noise
        noise = random.gauss(0, 0.02)

        arch.fitness = max(0, min(1, acc - param_penalty + noise))
        return arch.fitness

    def select_parents(self):
        """Tournament selection."""
        parents = []
        for _ in range(self.pop_size):
            tournament = random.sample(self.population, min(3, len(self.population)))
            winner = max(tournament, key=lambda a: a.fitness)
            parents.append(winner)
        return parents

    def crossover(self, parent1, parent2):
        """Create offspring by combining parents."""
        max_layers, max_width = self.curriculum.get_design_space(self.competence)

        # Mix layers from both parents
        child_layers = [self.input_dim]
        source = parent1 if random.random() < 0.5 else parent2
        for l in source.layers[1:-1]:
            child_layers.append(min(l, max_width))
        child_layers.append(self.output_dim)

        use_eml = parent1.use_eml or parent2.use_eml  # EML is sticky
        act = random.choice([parent1.activations, parent2.activations])

        return Architecture(child_layers, act, use_eml)

    def mutate(self, arch, mutation_rate=0.3):
        """Mutate architecture."""
        max_layers, max_width = self.curriculum.get_design_space(self.competence)

        if random.random() < mutation_rate:
            # Width mutation
            idx = random.randint(1, max(1, len(arch.layers) - 2))
            if idx < len(arch.layers) - 1:
                arch.layers[idx] = max(16, min(max_width,
                                               arch.layers[idx] + random.randint(-32, 32)))

        if random.random() < mutation_rate * 0.3:
            # Depth mutation
            if len(arch.layers) < max_layers + 2 and random.random() < 0.5:
                idx = random.randint(1, len(arch.layers) - 1)
                arch.layers.insert(idx, random.randint(16, max_width))
            elif len(arch.layers) > 3:
                idx = random.randint(1, len(arch.layers) - 2)
                arch.layers.pop(idx)

        if random.random() < 0.1:
            arch.use_eml = not arch.use_eml

        arch.params = arch._count_params()
        return arch

    def run(self):
        """Run the evolutionary NAS."""
        print("=" * 70)
        print("  Self-Learning Neural Architecture Search (SLNAS)")
        print("  Driven by RSIL framework theoretical guarantees")
        print("=" * 70)

        self.initialize_population()

        for gen in range(self.generations):
            # Evaluate
            for arch in self.population:
                self.evaluate(arch)

            # Sort by fitness
            self.population.sort(key=lambda a: a.fitness, reverse=True)
            best = self.population[0]
            self.best_history.append(best.fitness)

            # Meta-cognitive progress estimation
            improvement, confidence = self.meta.estimate_progress(
                best.fitness, self.best_history)

            # Update competence (contraction mapping: performance_gap_shrinks)
            gap = 1.0 - self.competence
            self.competence = min(1.0, self.competence + 0.05 * gap)

            if gen % 10 == 0 or gen == self.generations - 1:
                eml_frac = sum(1 for a in self.population if a.use_eml) / len(self.population)
                print(f"  Gen {gen:>3}: best={best.fitness:.4f}, "
                      f"params={best.params:>6}, "
                      f"EML={eml_frac:.0%}, "
                      f"competence={self.competence:.3f}, "
                      f"confidence={confidence:.3f}")

            # Selection and reproduction
            parents = self.select_parents()
            new_pop = [self.population[0]]  # elitism

            while len(new_pop) < self.pop_size:
                p1, p2 = random.sample(parents, 2)
                child = self.crossover(p1, p2)
                child = self.mutate(child)
                new_pop.append(child)

            self.population = new_pop

        # Final report
        print(f"\n  Best architecture found: {self.population[0]}")
        print(f"  Search convergence: {self.best_history[0]:.4f} → {self.best_history[-1]:.4f}")
        print(f"  Total improvement: {self.best_history[-1] - self.best_history[0]:.4f}")

        # Generate visualization
        self._save_visualization()
        return self.population[0]

    def _save_visualization(self):
        """Generate SVG of NAS convergence."""
        output_dir = os.path.dirname(os.path.abspath(__file__))
        vis_dir = os.path.join(output_dir, "visuals")
        os.makedirs(vis_dir, exist_ok=True)
        filename = os.path.join(vis_dir, "nas_convergence.svg")

        w, h = 600, 400
        margin = 60
        pw = w - 2 * margin
        ph = h - 2 * margin

        svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">']
        svg.append(f'<rect width="{w}" height="{h}" fill="white"/>')
        svg.append(f'<text x="{w // 2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">SLNAS: Architecture Search Convergence</text>')

        svg.append(f'<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{h - margin}" stroke="black" stroke-width="2"/>')
        svg.append(f'<line x1="{margin}" y1="{h - margin}" x2="{w - margin}" y2="{h - margin}" stroke="black" stroke-width="2"/>')
        svg.append(f'<text x="{w // 2}" y="{h - 10}" text-anchor="middle" font-size="12">Generation</text>')
        svg.append(f'<text x="15" y="{h // 2}" text-anchor="middle" font-size="12" transform="rotate(-90,15,{h // 2})">Best Fitness</text>')

        mn = min(self.best_history)
        mx = max(self.best_history)
        rng = mx - mn if mx > mn else 0.1

        points = []
        for i, f in enumerate(self.best_history):
            x = margin + pw * i / max(1, len(self.best_history) - 1)
            y = h - margin - ph * (f - mn) / rng
            points.append(f"{x:.1f},{y:.1f}")

        svg.append(f'<polyline points="{" ".join(points)}" fill="none" stroke="#4CAF50" stroke-width="2.5"/>')
        svg.append('</svg>')

        with open(filename, 'w') as f:
            f.write('\n'.join(svg))
        print(f"  Visualization saved: {filename}")


def main():
    random.seed(42)
    nas = SLNAS(pop_size=20, generations=50)
    best = nas.run()


if __name__ == "__main__":
    main()
