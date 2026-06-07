class EMLSpectralPair:
    def __init__(self, phase, logScale):
        self.phase = phase
        self.logScale = logScale
    
    def compose(self, other):
        return EMLSpectralPair(self.phase + other.phase, self.logScale + other.logScale)
    
    def quantum_gate(self):
        import numpy as np
        return np.exp(1j * self.phase)
    
    def eml_value(self):
        import numpy as np
        return np.exp(self.phase) - self.logScale