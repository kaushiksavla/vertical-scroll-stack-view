import UIKit
import Foundation

@resultBuilder struct StackComponentsBuilder<T> {
    
    static func buildBlock(_ components: T...) -> [T] {
        components
    }
    
}

final class VerticalScrollStackView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let verticalStackView = UIStackView()
    
    private let spacerView = UIView()
    
    init(inset: CGSize, spacing: CGFloat, @StackComponentsBuilder<UIView> components: () -> [UIView]) {
        super.init(frame: .zero)
        setup(inserting: components(), inset: inset, spacing: spacing)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    private func setup(inserting subviews: [UIView], inset: CGSize, spacing: CGFloat) {
        addSubview(scrollView)
        scrollView.snapEdges(to: self)
        
        scrollView.addSubview(contentView)
        contentView.snapEdgesTo(layoutGuide: scrollView.contentLayoutGuide)
        contentView.snapWidthHeightTo(layoutGuide: scrollView.frameLayoutGuide, heightConstraintPriority: .defaultLow)
        
        contentView.addSubview(verticalStackView)
        verticalStackView.spacing = spacing
        verticalStackView.axis = .vertical
        
        verticalStackView.snapVerticalEdges(to: contentView, verticalInset: inset.height)
        verticalStackView.snapHorizontalEdges(to: contentView, horizontalInset: inset.width)
        
        subviews.forEach { verticalStackView.addArrangedSubview($0) }
        verticalStackView.addArrangedSubview(spacerView)
        
        let spaceViewHeightConstraint = spacerView.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spaceViewHeightConstraint.isActive = true
        spaceViewHeightConstraint.priority = .defaultLow
    }
    
}

protocol StackViewModifiable {
    
    associatedtype View: UIView
    
    func setCustomBottomSpacing(_ spacing: CGFloat, after view: UIView) -> View
    
}

extension VerticalScrollStackView: StackViewModifiable {
    
    func setCustomBottomSpacing(_ spacing: CGFloat, after view: UIView) -> VerticalScrollStackView {
        verticalStackView.setCustomSpacing(spacing, after: view)
        return self
    }
    
}

// MARK: Constraints

extension UIView {
    
    // MARK: Base methods
    
    func snapVerticalEdges(to inputSuperview: UIView, verticalInset: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: inputSuperview.topAnchor, constant: verticalInset).isActive = true
        self.bottomAnchor.constraint(equalTo: inputSuperview.bottomAnchor, constant: -verticalInset).isActive = true
    }
    
    func snapHorizontalEdges(to inputSuperview: UIView, horizontalInset: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: inputSuperview.leadingAnchor, constant: horizontalInset).isActive = true
        self.trailingAnchor.constraint(equalTo: inputSuperview.trailingAnchor, constant: -horizontalInset).isActive = true
    }
    
    func snapEdges(to inputSuperview: UIView, inset: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        snapVerticalEdges(to: inputSuperview, verticalInset: inset)
        snapHorizontalEdges(to: inputSuperview, horizontalInset: inset)
    }
    
    // MARK: Layout guide methods
    
    func snapEdgesTo(layoutGuide: UILayoutGuide) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
    }
    
    func snapWidthHeightTo(layoutGuide: UILayoutGuide, heightConstraintPriority: UILayoutPriority) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = self.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
        widthConstraint.isActive = true
        
        let heightConstraint = self.heightAnchor.constraint(equalTo: layoutGuide.heightAnchor)
        heightConstraint.isActive = true
        heightConstraint.priority = heightConstraintPriority
    }
    
}
