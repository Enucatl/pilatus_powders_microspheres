import click
import h5py
import numpy as np
import csv


def filter_dataset(dataset, roi, flat):
    cropped_dataset = dataset[roi[1]:roi[3], roi[0]:roi[2]]
    cropped_flat = flat[roi[1]:roi[3], roi[0]:roi[2]]
    return cropped_dataset[np.where(cropped_flat != -1)]


@click.command()
@click.argument("filename", type=click.Path(exists=True))
@click.argument("roiname", type=click.Path(exists=True))
@click.argument("outputname", type=click.Path(exists=False))
def main(filename, roiname, outputname):
    dataset = h5py.File(filename)["postprocessing/dpc_reconstruction"]
    visibility = h5py.File(filename)["postprocessing/visibility"]
    flat = h5py.File(filename)[
        "postprocessing/flat_phase_stepping_curves"][..., 0]
    roi = [
        int(i)
        for i in open(roiname).read().split()
    ]
    absorption = filter_dataset(dataset[..., 0], roi, flat)
    differential_phase = filter_dataset(dataset[..., 1], roi, flat)
    dark_field = filter_dataset(dataset[..., 2], roi, flat)
    visibility = filter_dataset(visibility, roi, flat)
    with open(outputname, "w") as outputfile:
        writer = csv.writer(outputfile)
        writer.writerow(["A", "P", "B", "R", "v"])
        for a, p, b, v in zip(
                absorption,
                differential_phase,
                dark_field,
                visibility,
                ):
            writer.writerow([a, p, b, np.log(b) / np.log(a), v])

if __name__ == "__main__":
    main()
