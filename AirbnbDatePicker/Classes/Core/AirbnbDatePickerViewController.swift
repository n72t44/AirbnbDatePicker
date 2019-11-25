//
//  AirbnbDatePickerViewController.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 13/11/2017.
//  Copyright © 2017 mrfour. All rights reserved.
//

import UIKit

@objc public protocol AirbnbDatePickerViewControllerDelegate: class {
    @objc optional func datePickerController(_ picker: AirbnbDatePickerViewController, didFinishPicking dateInterval: DateInterval?)
    @objc optional func didDismissDatePickerController(_ picker: AirbnbDatePickerViewController)
}

public class AirbnbDatePickerViewController: UIViewController {
    private var noDismissNotification = false
    
    // MARK: - Public properties

    public weak var delegate: AirbnbDatePickerViewControllerDelegate?

    public var actionTitle: String = NSLocalizedString("Confirm", comment: "") {
        didSet {
            actionButton.setTitle(actionTitle, for: .normal)
        }
    }

    // MARK: - Private properties
    
    private let viewModel: AirbnbDatePickerViewModel
    private let calendar: Calendar
    private var isFirstLoad = true

    // MARK: - Views

    private var weekdayHeaderStackView: UIStackView!
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let headerView = UIView()
    private let titleView = AirbnbDatePickerTitleView(period: (nil, nil))
    private let clearButton = UIButton(type: .system)
    private var dismissButton : UIButton?
    private let actionButton = UIButton(type: .system)
    
    // MARK: - Life cycle

    public init(dateInterval: DateInterval, selectedDateInterval: DateInterval?, calendar: Calendar = Calendar.current) {
        self.calendar = calendar
        self.viewModel = AirbnbDatePickerViewModel(dateInterval: dateInterval, selectedDateInterval: selectedDateInterval, calendar: calendar)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 100, height: 100)

        prepareView()
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToSelectedDateOrToday(animated: false)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !noDismissNotification {
            delegate?.didDismissDatePickerController?(self)
        } else {
            noDismissNotification = true
        }
    }
}

// MARK: - Button events

public extension AirbnbDatePickerViewController {
    @objc func didClickActionButton(_ button: UIButton) {
        noDismissNotification = true
        dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.datePickerController?(self, didFinishPicking: self.viewModel.selectedDateInterval)
        }
    }

    @objc func didClickClearButton(_ button: UIButton) {
        viewModel.clear()
        updateUI()
    }
    
    @objc func didClickDismissButton(_ button: UIButton) { // TODO
        noDismissNotification = false
        dismiss(animated: true)
    }
}


// MARK: - Prepare view

fileprivate extension AirbnbDatePickerViewController {
    func prepareView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = ThemeManager.current.headFootColor ?? .systemBackground
        } else {
            view.backgroundColor = ThemeManager.current.headFootColor ?? .white
        }
        
        prepareTitleView()
        prepareCollectionView()
        prepareWeekdayStackView()
        prepareActionButton()
        prepareSubviewConstriats()

        updateUI()
    }

    func prepareTitleView() {
        clearButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        clearButton.setTitleColor(.button, for: .normal)
        clearButton.setTitleColor(.disabled, for: .disabled)

        clearButton.titleLabel?.font = Font.medium(ofSize: Font.smallSize)
        clearButton.addTarget(self, action: #selector(didClickClearButton(_:)), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let dismissIcon = ThemeManager.current.dismissIcon {
            dismissButton = UIButton(type: .custom)
            dismissButton?.setImage(dismissIcon, for: .normal)
            dismissButton?.tintColor = .button
        } else {
            dismissButton = UIButton(type: .system)
            dismissButton?.setTitle(NSLocalizedString("Dismiss", comment: ""), for: .normal)
            dismissButton?.setTitleColor(.button, for: .normal)
            dismissButton?.titleLabel?.font = Font.regular(ofSize: Font.smallSize)
        }
        dismissButton?.addTarget(self, action: #selector(didClickDismissButton(_:)), for: .touchUpInside)
        dismissButton?.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.translatesAutoresizingMaskIntoConstraints = false

        if ThemeManager.current.modal && dismissButton != nil {
            headerView.addSubview(dismissButton!)
        }
        headerView.addSubview(titleView)
        headerView.addSubview(clearButton)

        NSLayoutConstraint.activate([
            titleView.separator.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            clearButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
        if ThemeManager.current.modal && dismissButton != nil {
            NSLayoutConstraint.activate([
                dismissButton!.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                dismissButton!.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20)
            ])
        }
    }
    
    func prepareCollectionView() {
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.register(AirbnbDatePickerCollectionViewCell.self, forCellWithReuseIdentifier: AirbnbDatePickerCollectionViewCell.className)
        collectionView.register(AirbnbDatePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AirbnbDatePickerHeaderView.className)
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.dataSource = viewModel
        collectionView.delegate = self
    }

    func prepareActionButton() {
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.setTitleColor(.button, for: .normal)
        actionButton.setTitleColor(.disabled, for: .disabled)
        actionButton.titleLabel?.font = Font.medium(ofSize: Font.mediumSize)
        actionButton.addTarget(self, action: #selector(didClickActionButton), for: .touchUpInside)
    }

    func prepareWeekdayStackView() {
        let arrangedSubviews = calendar.veryShortWeekdaySymbols.map { symbol -> UILabel in
            let label = UILabel()
            label.text = symbol
            label.textColor = .legend
            label.font = Font.medium(ofSize: 13)
            label.textAlignment = .center
            
            return label
        }
        
        weekdayHeaderStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        
        weekdayHeaderStackView.alignment = .center
        weekdayHeaderStackView.axis = .horizontal
        weekdayHeaderStackView.distribution = .fillEqually
    }
    
    func prepareSubviewConstriats() {
        let headerSeparator = UIView()
        headerSeparator.backgroundColor = .separator

        let footerSeparator = UIView()
        footerSeparator.backgroundColor = .separator

        let stackView = UIStackView(arrangedSubviews: [headerView, weekdayHeaderStackView, headerSeparator, collectionView, footerSeparator, actionButton])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        view.addSubview(stackView)
        /*if UIDevice.current.userInterfaceIdiom == .pad && !ThemeManager.current.modal {
            NSLayoutConstraint.activate([
                headerView.heightAnchor.constraint(equalToConstant: Config.headerViewHeight),
                weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight),
                headerSeparator.heightAnchor.constraint(equalToConstant: 1),
                footerSeparator.heightAnchor.constraint(equalToConstant: 1),
                actionButton.heightAnchor.constraint(equalToConstant: 44),
                stackView.widthAnchor.constraint(equalToConstant: 400),
                stackView.heightAnchor.constraint(equalToConstant: 600),
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        } else {*/
            if #available(iOS 11.0, *) {
                NSLayoutConstraint.activate([
                    headerView.heightAnchor.constraint(equalToConstant: Config.headerViewHeight),
                    weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight),
                    headerSeparator.heightAnchor.constraint(equalToConstant: 1),
                    footerSeparator.heightAnchor.constraint(equalToConstant: 1),
                    actionButton.heightAnchor.constraint(equalToConstant: 44),
                    stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    headerView.heightAnchor.constraint(equalToConstant: Config.headerViewHeight),
                    weekdayHeaderStackView.heightAnchor.constraint(equalToConstant: Config.weekdayHeaderHeight),
                    headerSeparator.heightAnchor.constraint(equalToConstant: 1),
                    footerSeparator.heightAnchor.constraint(equalToConstant: 1),
                    actionButton.heightAnchor.constraint(equalToConstant: 44),
                    stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
        //}
    }
}

// MARK: - Private functions

fileprivate extension AirbnbDatePickerViewController {
    /// Scroll the collection view (calendar) to the `start` of `selectedDateInterval`, if `selectedDateInterval` is `nil, then scroll to today.
    func scrollToSelectedDateOrToday(animated: Bool) {
        view.layoutIfNeeded()
        
        let dateToScroll = viewModel.selectedDateInterval?.start ?? Date()
        guard let indexPath = viewModel.indexPath(for: dateToScroll) else { return }
        collectionView.scrollToSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath, at: .top, animated: animated)
    }

    func updateUI() {
        collectionView.reloadData()
        updateTitle()

        actionButton.setEnabled(viewModel.selectedStartDate == nil || viewModel.selectedEndDate != nil, animated: true)
        clearButton.setEnabled(viewModel.selectedStartDate != nil, animated: true)
    }

    func updateTitle() {
        titleView.period = (viewModel.selectedStartDate, viewModel.selectedEndDate)
    }
}

// MARK: - Collection delegate

extension AirbnbDatePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectDay(at: indexPath)
        updateUI()
    }
}

// MARK: - Collection flow layout

extension AirbnbDatePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return interItemSize(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Config.lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemSize = interItemSize(in: collectionView)
        let horizonInset = (collectionView.frame.width - itemSize.width*Config.numberOfWeekday) / 2
        let insets = UIEdgeInsets(vertical: Config.sectionVerticalInset, horizontal: horizonInset)
        return insets
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func interItemSize(in colletionView: UICollectionView) -> CGSize {
        let width = ceil((collectionView.frame.width - Config.sectionHorizonInset*2) / Config.numberOfWeekday)
        let height = width - Config.itemSpacing
        return CGSize(width: width, height: height)
    }
}

// MARK: - Configuration

fileprivate extension AirbnbDatePickerViewController {
    enum Config {
        static let itemSpacing: CGFloat = 4
        static let lineSpacing: CGFloat = 4
        static let numberOfWeekday: CGFloat = 7
        static let sectionVerticalInset: CGFloat = 8
        static let sectionHorizonInset: CGFloat = 0
        static let weekdayHeaderHeight: CGFloat = 32
        static let headerViewHeight: CGFloat = 44

        static let titleFont = Font.medium(ofSize: Font.smallSize)
    }
}
