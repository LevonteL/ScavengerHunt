//
//  TaskDetailViewController.swift
//  ScavengerHunt
//

import UIKit
import PhotosUI
import MapKit
import Photos

class TaskDetailViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Task

    var task: Task?
    var taskTitle: String?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = task?.title ?? taskTitle ?? "Task Detail"

        // Task title
        taskTitleLabel.text = task?.title ?? "Task"
        taskTitleLabel.numberOfLines = 0
        taskTitleLabel.lineBreakMode = .byWordWrapping

        // Task description
        taskDescriptionLabel.text =
            task?.description ?? "Take a photo to complete this task."

        taskDescriptionLabel.numberOfLines = 0
        taskDescriptionLabel.lineBreakMode = .byWordWrapping

        // Allow labels to use their available width
        taskTitleLabel.adjustsFontSizeToFitWidth = true
        taskTitleLabel.minimumScaleFactor = 0.7

        taskDescriptionLabel.adjustsFontSizeToFitWidth = true
        taskDescriptionLabel.minimumScaleFactor = 0.7

        // Photo appearance
        taskImageView.contentMode = .scaleAspectFill
        taskImageView.clipsToBounds = true
    }

    // MARK: - Attach Photo

    @IBAction func attachPhotoTapped(_ sender: UIButton) {

        var configuration =
            PHPickerConfiguration(photoLibrary: .shared())

        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker =
            PHPickerViewController(configuration: configuration)

        picker.delegate = self

        present(picker, animated: true)
    }

    // MARK: - Photo Location

    private func showLocation(for assetIdentifier: String) {

        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetIdentifier],
            options: nil
        )

        guard let asset = assets.firstObject,
              let location = asset.location else {

            showNoLocationAlert()
            return
        }

        let coordinate = location.coordinate

        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()

        annotation.coordinate = coordinate
        annotation.title =
            task?.title ?? "Photo Location"

        annotation.subtitle =
            "This photo was taken here"

        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        )

        mapView.setRegion(
            region,
            animated: true
        )
    }

    // MARK: - No Location Alert

    private func showNoLocationAlert() {

        let alert = UIAlertController(
            title: "No Location Found",
            message: """
            This photo does not contain location information. \
            Try selecting a photo that was taken with location services enabled.
            """,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }
}


// MARK: - PHPicker Delegate

extension TaskDetailViewController:
    PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(animated: true)

        guard let result = results.first else {
            return
        }

        let assetIdentifier =
            result.assetIdentifier

        guard result.itemProvider.canLoadObject(
            ofClass: UIImage.self
        ) else {
            return
        }

        result.itemProvider.loadObject(
            ofClass: UIImage.self
        ) { [weak self] object, error in

            guard let image =
                    object as? UIImage else {
                return
            }

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                // Show photo
                self.taskImageView.image = image

                // Complete task
                self.task?.isCompleted = true

                // Show location
                if let assetIdentifier =
                    assetIdentifier {

                    self.showLocation(
                        for: assetIdentifier
                    )

                } else {

                    self.showNoLocationAlert()
                }
            }
        }
    }
}
