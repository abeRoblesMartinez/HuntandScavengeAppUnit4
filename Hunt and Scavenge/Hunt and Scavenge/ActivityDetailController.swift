//
//  ActivityDetailController.swift
//  Hunt and Scavenge
//
//  Created by Abraham on 3/2/23.
//

import UIKit
import MapKit
import UIKit
import PhotosUI

class ActivityDetailController: UIViewController, PHPickerViewControllerDelegate, MKMapViewDelegate {
    

    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var attachPhotoButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var activity: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.register(ActivityAnnotationView.self, forAnnotationViewWithReuseIdentifier: ActivityAnnotationView.identifier)
        
        mapView.delegate = self

        mapView.layer.cornerRadius = 12
        updateUI()
        updateMapView()
        
    }
    
    
    private func updateUI() {
        activityLabel.text = activity.title
        descriptionLabel.text = activity.description

        let completedImage = UIImage(systemName: activity.isComplete ? "circle.dashed.inset.filled" : "circle")

        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = activity.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = activity.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !activity.isComplete
        attachPhotoButton.isHidden = activity.isComplete
    }

    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // Request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }
    }
    

    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)
    }

    func updateMapView() {
        // TODO: Set map viewing region and scale
        guard let imageLocation = activity.imageLocation else { return }
        let coordinate = imageLocation.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

// TODO: Conform to PHPickerViewControllerDelegate + implement required method(s)

// TODO: Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.

// Helper methods to present various alerts
extension ActivityDetailController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo of your activity, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        let result = results.first
            guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        print("Image location coordinate: \(location.coordinate)")
        
        guard let provider = result?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            if let error = error {
              DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            
            }

            guard let image = object as? UIImage else { return }

            print("🌉 We have an image!")

            DispatchQueue.main.async { [weak self] in

                self?.activity.set(image, with: location)

                self?.updateUI()

                self?.updateMapView()
            }
        }

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ActivityAnnotationView.identifier, for: annotation) as? ActivityAnnotationView else {
            fatalError("Unable to dequeue ActivityAnnotationView")
        }

        // Configure the annotation view, passing in the task's image.
        annotationView.configure(with: activity.image)
        return annotationView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


