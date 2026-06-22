from dataclasses import dataclass
from fractions import Fraction
from typing import Union

Val = Union[int, float]

@dataclass(frozen=True)
class DefectReport:
    v_x: Val
    v_y: Val
    v_sum: Val
    predicted: Val
    is_defect: bool
    is_tie: bool

def analyze_pair(x: Fraction, y: Fraction, p: int,
                 v) -> DefectReport:
    vx, vy = v(x, p), v(y, p)
    vsum = v(x + y, p)
    predicted = min(vx, vy)
    assert predicted <= vsum                 # sub-additivity
    if vx != vy:
        assert vsum == predicted             # additivity off ties
    report = DefectReport(vx, vy, vsum, predicted,
                          vsum != predicted, vx == vy)
    if report.is_defect:
        assert report.is_tie                 # defect => tie
    return report
