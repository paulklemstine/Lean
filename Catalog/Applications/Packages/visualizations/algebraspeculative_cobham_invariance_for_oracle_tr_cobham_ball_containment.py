from typing import List, Tuple, Set, Callable, Optional, Dict
import itertools
from dataclasses import dataclass
from typing import List, Callable, Tuple, Dict
import random
import math
from algorithms import lcvp_depth, make_drop_prefix, make_append_suffix
from typing import List, Tuple, Dict, Any
import itertools
import itertools
import math
import base64
import io

def check_cobham_ball_containment(
    forward_fn: Callable[[List[int]], List[int]],
    backward_fn: Callable[[List[int]], List[int]],
    forward_depth_loss: int,
    backward_depth_loss: int,
    center: List[int],
    radius: int,
    alphabet: List[int],
    max_length: int
) -> Dict[str, bool]:
    """
    Check the Cobham invariance ball containment property.

    Verifies:
    1. forward(traceBall(c, r + d_fwd)) ⊆ traceBall(forward(c), r)
    2. backward(traceBall(forward(c), r + d_bwd)) ⊆ traceBall(backward(forward(c)), r)

    Time complexity: O(|Σ|^max_length * max_length)

    Parameters
    ----------
    forward_fn, backward_fn : Callable
        Forward and backward transducer functions
    forward_depth_loss, backward_depth_loss : int
        Depth loss bounds
    center : List[int]
        Center trace for the ball
    radius : int
        Ball radius
    alphabet : List[int]
        Trace alphabet
    max_length : int
        Max trace length for enumeration

    Returns
    -------
    Dict[str, bool]
        Results of forward and backward containment checks
    """
    # Forward check
    input_ball = enumerate_trace_ball(center, radius + forward_depth_loss,
                                       alphabet, max_length)
    fwd_center = forward_fn(center)
    output_ball_set = {tuple(t) for t in
                       enumerate_trace_ball(fwd_center, radius, alphabet, max_length + 10)}

    fwd_ok = all(tuple(forward_fn(t)) in output_ball_set for t in input_ball)

    # Backward check
    bwd_input_ball = enumerate_trace_ball(fwd_center, radius + backward_depth_loss,
                                           alphabet, max_length)
    bwd_center = backward_fn(fwd_center)
    bwd_output_ball_set = {tuple(t) for t in
                           enumerate_trace_ball(bwd_center, radius, alphabet, max_length + 10)}

    bwd_ok = all(tuple(backward_fn(t)) in bwd_output_ball_set for t in bwd_input_ball)

    return {
        "forward_containment": fwd_ok,
        "backward_containment": bwd_ok,
        "input_ball_size": len(input_ball),
        "output_ball_size": len(output_ball_set),
    }