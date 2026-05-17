# See algorithms.py for full implementation
def simulation_transfer(simulator, circuit):
    return dualize(simulator(dualize(circuit)))