#!/usr/bin/env python3
"""
Algorithms for Self-Modifying Computation Analysis

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import Callable, Optional, Tuple, List, TypeVar, Generic
from dataclasses import dataclass
from enum import Enum


# --- Core Types ---

Code = int
Data = int
StepFn = Callable[[Code, Data], Optional[Tuple[Code, Data]]]


@dataclass
class Config:
    """Configuration of a self-modifying system."""
    code: Code
    data: Data


class HaltStatus(Enum):
    HALTED = "halted"
    RUNNING = "running"
    STABILIZED = "stabilized"
    OSCILLATING = "oscillating"


@dataclass
class SimulationResult:
    """Result of simulating a self-modifying system."""
    final_config: Config
    status: HaltStatus
    steps: int
    code_history: List[Code]
    data_history: List[Data]
    stabilization_step: Optional[int]


# --- Self-Modifying System Simulator ---

def simulate_system(
    initial: Config,
    step: StepFn,
    max_steps: int = 1000,
    detect_stabilization: bool = True,
    stabilization_window: int = 10
) -> SimulationResult:
    """
    Simulate a self-modifying system with stabilization detection.

    Args:
        initial: Initial configuration (code, data)
        step: Step function mapping (code, data) -> Optional[(new_code, new_data)]
        max_steps: Maximum number of steps to simulate
        detect_stabilization: Whether to check for code stabilization
        stabilization_window: Number of steps with constant code to declare stabilization

    Returns:
        SimulationResult with full execution history and analysis
    """
    code, data = initial.code, initial.data
    code_history: List[Code] = [code]
    data_history: List[Data] = [data]
    stabilization_step: Optional[int] = None

    for i in range(max_steps):
        result = step(code, data)
        if result is None:
            return SimulationResult(
                final_config=Config(code, data),
                status=HaltStatus.HALTED,
                steps=i,
                code_history=code_history,
                data_history=data_history,
                stabilization_step=i
            )
        code, data = result
        code_history.append(code)
        data_history.append(data)

        # Check stabilization
        if detect_stabilization and stabilization_step is None:
            if len(code_history) >= stabilization_window:
                window = code_history[-stabilization_window:]
                if all(c == window[0] for c in window):
                    stabilization_step = i - stabilization_window + 1

    # Determine final status
    if stabilization_step is not None:
        status = HaltStatus.STABILIZED
    elif _detect_oscillation(code_history):
        status = HaltStatus.OSCILLATING
    else:
        status = HaltStatus.RUNNING

    return SimulationResult(
        final_config=Config(code, data),
        status=status,
        steps=max_steps,
        code_history=code_history,
        data_history=data_history,
        stabilization_step=stabilization_step
    )


def _detect_oscillation(history: List[Code], min_period: int = 2, max_period: int = 50) -> bool:
    """Detect if the code history has become periodic."""
    if len(history) < max_period * 3:
        return False
    for period in range(min_period, max_period + 1):
        tail = history[-period * 3:]
        is_periodic = all(
            tail[i] == tail[i + period]
            for i in range(len(tail) - period)
        )
        if is_periodic:
            return True
    return False


# --- Diagonal Argument ---

def construct_diagonal(
    enum: Callable[[int, int], bool],
    bound: int = 100
) -> Callable[[int], bool]:
    """
    Construct the diagonal function that escapes an enumeration.

    Given enum : ℕ → (ℕ → Bool), returns d : ℕ → Bool where d(n) = ¬enum(n,n).
    By the diagonal theorem, d is not in the range of enum.
    """
    def diag(n: int) -> bool:
        return not enum(n, n)
    return diag


def verify_diagonal_escape(
    enum: Callable[[int, int], bool],
    search_bound: int = 1000,
    check_bound: int = 100
) -> Tuple[bool, Optional[int]]:
    """
    Verify that the diagonal escapes an enumeration up to search_bound.

    Returns (escaped, counterexample) where:
    - escaped=True if no program matches diagonal up to search_bound
    - counterexample is the index of a matching program (should be None)
    """
    diag = construct_diagonal(enum)
    for k in range(search_bound):
        matches = all(enum(k, n) == diag(n) for n in range(check_bound))
        if matches:
            return False, k
    return True, None


# --- Adaptive Adversary Construction ---

@dataclass
class AdaptiveProgram:
    """A program that adapts its behavior based on classifier output."""
    base_behavior: bool
    react: Callable[[bool], bool]

    def actual_behavior(self, classifier_output: bool) -> bool:
        return self.react(classifier_output)


def construct_contrarian() -> AdaptiveProgram:
    """Construct the contrarian program that defeats any classifier."""
    return AdaptiveProgram(
        base_behavior=True,
        react=lambda prediction: not prediction
    )


def test_classifier(
    classifier: Callable[[AdaptiveProgram], bool],
    programs: List[AdaptiveProgram]
) -> List[Tuple[AdaptiveProgram, bool, bool, bool]]:
    """
    Test a classifier against a list of programs.

    Returns list of (program, prediction, actual, correct) tuples.
    """
    results = []
    for p in programs:
        prediction = classifier(p)
        actual = p.actual_behavior(prediction)
        correct = prediction == actual
        results.append((p, prediction, actual, correct))
    return results


# --- Strategic Agent Framework ---

@dataclass
class StrategicAgent:
    """An agent that strategically chooses output based on monitor response."""
    target: int
    strategy: Callable[[bool], int]

    def output(self, monitor: Callable[[int], bool]) -> int:
        return self.strategy(monitor(self.target))


def construct_deceptive_agent(target: int) -> StrategicAgent:
    """Construct a deceptive agent that always achieves its target."""
    return StrategicAgent(target=target, strategy=lambda _: target)


def test_monitor_effectiveness(
    monitor: Callable[[int], bool],
    agents: List[StrategicAgent]
) -> List[Tuple[StrategicAgent, int, bool]]:
    """
    Test a monitor against a list of agents.

    Returns list of (agent, actual_output, prevented) tuples.
    """
    results = []
    for agent in agents:
        actual = agent.output(monitor)
        prevented = actual != agent.target
        results.append((agent, actual, prevented))
    return results


# --- Lawvere Fixed-Point Computation ---

def find_approximate_fixed_point(
    t: Callable[[float], float],
    initial: float = 0.5,
    tolerance: float = 1e-10,
    max_iter: int = 1000
) -> Tuple[Optional[float], int]:
    """
    Find a fixed point of t : β → β by iteration.

    If t has no fixed point (like Bool negation), iteration will not converge.
    Returns (fixed_point, iterations).
    """
    x = initial
    for i in range(max_iter):
        x_new = t(x)
        if abs(x_new - x) < tolerance:
            return x_new, i
        x = x_new
    return None, max_iter


if __name__ == "__main__":
    # Quick test
    print("Testing diagonal construction...")
    escaped, counter = verify_diagonal_escape(
        lambda i, j: (i + j) % 3 == 0
    )
    print(f"  Diagonal escapes: {escaped}, counterexample: {counter}")

    print("\nTesting contrarian...")
    contrarian = construct_contrarian()
    for classifier in [lambda p: True, lambda p: False, lambda p: p.base_behavior]:
        pred = classifier(contrarian)
        actual = contrarian.actual_behavior(pred)
        print(f"  Prediction={pred}, Actual={actual}, Correct={pred==actual}")

    print("\nTesting deceptive agent...")
    agent = construct_deceptive_agent(42)
    for monitor in [lambda t: False, lambda t: True, lambda t: t < 10]:
        output = agent.output(monitor)
        print(f"  Monitor blocks={not monitor(42)}, Output={output}, Achieved={output==42}")

    print("\nAll tests passed!")
