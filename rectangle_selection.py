import click
import h5py
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
from matplotlib.widgets import RectangleSelector
import csv


@click.command()
@click.argument("filename", type=click.Path(exists=True))
@click.argument("outputname", type=click.Path(exists=False))
def main(filename, outputname):
    dataset = h5py.File(filename)["postprocessing/dpc_reconstruction"][
        ..., 0]
    fig, ax = plt.subplots()
    # limits = [0.7, 1]
    limits = stats.mstats.mquantiles(dataset, prob=[0.02, 0.98])
    print(limits)
    image = ax.imshow(dataset, interpolation="none", aspect='auto')
    image.set_clim(*limits)

    def onselect(eclick, erelease):
        global startpos
        global endpos
        startpos = [int(eclick.xdata), int(eclick.ydata)]
        endpos = [int(erelease.xdata), int(erelease.ydata)]

    plt.ion()
    lasso = RectangleSelector(ax, onselect, lineprops={"color": "red"})
    plt.show()
    input('Press any key to accept selected points')
    with open(outputname, "w") as outputfile:
        output = " ".join([str(i) for i in startpos + endpos])
        print(output, file=outputfile)

if __name__ == "__main__":
    main()
