//
//  KeyboardViewController.swift
//  KazakhKeyboard
//
//  Created by 叶得力 on 2024/12/27.
//

import UIKit

/// 一个简单的按键信息模型
struct KazakhKey {
    var title: String            // 按键主显示文字
    var longPressValues: [String] // 长按可选值 (如数字)
    var widthMultiplier: CGFloat? // 可用于特殊按键（如空格）占用更大宽度
}

// 气泡视图：供长按时显示可选字符的简化示例
class BalloonView: UIView {
    
    private var stackView = UIStackView()
    var onCharacterSelected: ((String) -> Void)?
    
    init(options: [String]) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for opt in options {
            let btn = UIButton(type: .system)
            btn.setTitle(opt, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            btn.setTitleColor(.black, for: .normal)
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 4
            
            btn.addAction(UIAction(handler: { [weak self] _ in
                self?.onCharacterSelected?(opt)
            }), for: .touchUpInside)
            
            stackView.addArrangedSubview(btn)
        }
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    
    /// 用于跟踪当前是否展示符号键盘（示例中仅演示逻辑，可自行实现）
    var isShowingSymbols = false
    
    /// 第一行按键信息（长按弹出数字）
    let firstRowKeys: [KazakhKey] = [
        KazakhKey(title: "چ", longPressValues: ["چ"], widthMultiplier: nil),
        KazakhKey(title: "ۋ", longPressValues: ["ۋ"], widthMultiplier: nil),
        KazakhKey(title: "ء", longPressValues: ["ء"], widthMultiplier: nil),
        KazakhKey(title: "ر", longPressValues: ["ر"], widthMultiplier: nil),
        KazakhKey(title: "ت", longPressValues: ["ت"], widthMultiplier: nil),
        KazakhKey(title: "ي", longPressValues: ["ي"], widthMultiplier: nil),
        KazakhKey(title: "ۇ", longPressValues: ["ۇ"], widthMultiplier: nil),
        KazakhKey(title: "ڭ", longPressValues: ["ڭ"], widthMultiplier: nil),
        KazakhKey(title: "و", longPressValues: ["و"], widthMultiplier: nil),
        KazakhKey(title: "پ", longPressValues: ["پ"], widthMultiplier: nil),
        KazakhKey(title: "ف", longPressValues: ["ف"], widthMultiplier: nil)
    ]

    
    /// 第二行按键信息（你可继续补充长按内容）
    let secondRowKeys: [KazakhKey] = [
        KazakhKey(title: "ھ", longPressValues: ["ھ"], widthMultiplier: nil),
        KazakhKey(title: "س", longPressValues: ["س"], widthMultiplier: nil),
        KazakhKey(title: "د", longPressValues: ["د"], widthMultiplier: nil),
        KazakhKey(title: "ا", longPressValues: ["ا"], widthMultiplier: nil),
        KazakhKey(title: "ه", longPressValues: ["ه"], widthMultiplier: nil),
        KazakhKey(title: "ى", longPressValues: ["ى"], widthMultiplier: nil),
        KazakhKey(title: "ق", longPressValues: ["ق"], widthMultiplier: nil),
        KazakhKey(title: "ك", longPressValues: ["ك"], widthMultiplier: nil),
        KazakhKey(title: "ل", longPressValues: ["ل"], widthMultiplier: nil),
        KazakhKey(title: "گ", longPressValues: ["گ"], widthMultiplier: nil)
    ]

    
    /// 第三行按键信息（示例：含部分字母和删除键等）
    /// 开头 “符号”/“ABC” 键不在此列示例，会在布局中单独添加
    let thirdRowKeys: [KazakhKey] = [
        KazakhKey(title: "ز", longPressValues: ["ز"], widthMultiplier: nil),
        KazakhKey(title: "ش", longPressValues: ["ش"], widthMultiplier: nil),
        KazakhKey(title: "ع", longPressValues: ["ع"], widthMultiplier: nil),
        KazakhKey(title: "ۆ", longPressValues: ["ۆ"], widthMultiplier: nil),
        KazakhKey(title: "ب", longPressValues: ["ب"], widthMultiplier: nil),
        KazakhKey(title: "ن", longPressValues: ["ن"], widthMultiplier: nil),
        KazakhKey(title: "م", longPressValues: ["م"], widthMultiplier: nil),
        KazakhKey(title: "ح", longPressValues: ["ح"], widthMultiplier: nil),
        KazakhKey(title: "ج", longPressValues: ["ج"], widthMultiplier: nil)
    ]

    // MARK: - Lifecycle
    
    private var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 构建键盘 UI
        setupKeyboard()

        // 创建高度约束并激活
        heightConstraint = NSLayoutConstraint(
            item: self.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 280 // 你想要的高度
        )
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }
    
    // MARK: - Custom Keyboard Layout
    
    
    /// 构建整个键盘布局
    private func setupKeyboard() {
        
        // 让键盘背景变灰色
        self.view.backgroundColor = .systemGray4
        
        // 垂直方向用一个整体的 UIStackView 来容纳所有行
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fillEqually   // 每一行高度相等
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加到 self.view
        self.view.addSubview(mainStack)
        
        // 布局约束：让 mainStack 上下左右贴合键盘可用区域
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6),
            mainStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6),
            mainStack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 6),
            mainStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -6)
        ])
        
        // 1) 第一行
        let firstRowStack = createRowStackView(keys: firstRowKeys)
        mainStack.addArrangedSubview(firstRowStack)
        
        // 2) 第二行
        let secondRowStack = createRowStackView(keys: secondRowKeys)
        mainStack.addArrangedSubview(secondRowStack)
        
        // 3) 第三行
        //    在第三行开头加一个 “符号 / ABC” 切换按钮
        //    在第三行末尾加一个 “删除键”
        let thirdRowStack = UIStackView()
        thirdRowStack.axis = .horizontal
        thirdRowStack.alignment = .fill
        thirdRowStack.distribution = .fillEqually
        thirdRowStack.spacing = 6
        
        // “符号/ABC”按钮
        let symbolButton = createSystemButton(title: "123") {
            [weak self] in
            self?.toggleSymbolKeyboard()
        }
        // 宽度和其他按键一样，这里使用 fillEqually，可不额外设置
        
        thirdRowStack.addArrangedSubview(symbolButton)
        
        // 中间若干字母
        for key in thirdRowKeys {
            let keyButton = createKeyButton(key: key)
            thirdRowStack.addArrangedSubview(keyButton)
        }
        
        // “删除”按钮
        let deleteButton = createSystemButton(title: "⌫") {
            [weak self] in
            self?.textDocumentProxy.deleteBackward()
        }
        thirdRowStack.addArrangedSubview(deleteButton)
        
        mainStack.addArrangedSubview(thirdRowStack)
        
        // 4) 最后一行（功能行：123、🌐、空格、完成）
        let functionRowStack = UIStackView()
        functionRowStack.axis = .horizontal
        functionRowStack.alignment = .fill
        functionRowStack.distribution = .fillProportionally
        functionRowStack.spacing = 6
        
        // (1) "123" 符号键切换(示例)
        let numberButton = createSystemButton(title: "表情包") {
            [weak self] in
            self?.toggleSymbolKeyboard()
        }
        numberButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        functionRowStack.addArrangedSubview(numberButton)
        
        // (2) 语言切换键 (🌐)
        // 这里系统也会注入 nextKeyboardButton，如果 needsInputModeSwitchKey == true，则需用 handleInputModeList
        // 以下是自定义一个🌐，点击后调用 advanceToNextInputMode()
        let globeButton = createSystemButton(title: "🌐") {
            [weak self] in
            self?.advanceToNextInputMode()
        }
        globeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        functionRowStack.addArrangedSubview(globeButton)
        
        // (3) 空格键 (可加大宽度)
        let spaceButton = createSystemButton(title: "空格") {
            [weak self] in
            self?.textDocumentProxy.insertText(" ")
        }
        // 不手动固定宽度，fillProportionally会让它自动分配剩余空间
        functionRowStack.addArrangedSubview(spaceButton)
        
        // (4) 完成键 (换行)
        let returnButton = createSystemButton(title: "完成") {
            [weak self] in
            // 一般第三方键盘无法直接关闭键盘，但可以插入换行符
            self?.textDocumentProxy.insertText("\n")
        }
        returnButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        functionRowStack.addArrangedSubview(returnButton)
        
        mainStack.addArrangedSubview(functionRowStack)
        
    }
    
    /// 创建每一行的 UIStackView（仅放字母按键）
    private func createRowStackView(keys: [KazakhKey]) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.distribution = .fillEqually
        rowStack.spacing = 6
        
        for key in keys {
            let keyButton = createKeyButton(key: key)
            rowStack.addArrangedSubview(keyButton)
        }
        
        return rowStack
    }
    
    /// 创建普通字母键按钮（含长按弹出数字示例）
    private func createKeyButton(key: KazakhKey) -> UIButton {
        let button = UIButton(type: .system)
        // 1) 主文字
        button.setTitle(key.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5

        // 2) 如果有长按可选字符，就在按钮上方加一行小字
        if !key.longPressValues.isEmpty {
            let topLabel = UILabel()
            topLabel.font = .systemFont(ofSize: 10, weight: .regular)
            topLabel.textColor = .darkGray
            // 显示所有可选字符拼在一起，或只显示第一个
            topLabel.text = key.longPressValues.joined(separator: " ")
            topLabel.textAlignment = .center

            // 把这个 topLabel 加进按钮
            // 可用 Auto Layout，也可用 frame 布局
            //topLabel.translatesAutoresizingMaskIntoConstraints = false
            //button.addSubview(topLabel)

            // 让 topLabel 贴顶部
            //NSLayoutConstraint.activate([
                //topLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
               // topLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 2)
            //])
        }

        // 3) 点击 & 长按
        button.addTarget(self, action: #selector(keyTapAction(_:)), for: .touchUpInside)
        if !key.longPressValues.isEmpty {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
            button.addGestureRecognizer(longPress)
        }
        return button
    }

    
    /// 创建系统功能按钮（如“符号”、“删除”），可自定义样式
    private func createSystemButton(title: String, action: @escaping ()->Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        
        // 用 closure 包装
        button.addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    
    /// 点击输入字母
    @objc private func keyTapAction(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        textDocumentProxy.insertText(title)
    }
    
    /// 长按手势：弹出数字或额外符号等
    @objc private func longPressAction(_ gesture: UILongPressGestureRecognizer) {
            guard let button = gesture.view as? UIButton else { return }
            
            switch gesture.state {
            case .began:
                let theKey = findKey(by: button.currentTitle ?? "")
                guard let key = theKey, !key.longPressValues.isEmpty else { return }
                
                // 创建气泡
                let balloon = BalloonView(options: key.longPressValues)
                balloon.onCharacterSelected = { selectedChar in
                    self.textDocumentProxy.insertText(selectedChar)
                    balloon.removeFromSuperview()
                }
                
                // 定位
                let btnFrame = button.superview?.convert(button.frame, to: self.view) ?? .zero
                let balloonWidth: CGFloat = CGFloat(50 * key.longPressValues.count)
                let balloonHeight: CGFloat = 50
                
                balloon.frame = CGRect(
                    x: btnFrame.midX - balloonWidth / 2,
                    y: btnFrame.minY - balloonHeight - 8,
                    width: balloonWidth,
                    height: balloonHeight
                )
                
                self.view.addSubview(balloon)
                
            case .ended, .cancelled, .failed:
                // 移除所有气泡
                for sub in self.view.subviews where sub is BalloonView {
                    sub.removeFromSuperview()
                }
            default:
                break
            }
        }
    
    /// 寻找对应的 KazakhKey
    private func findKey(by title: String) -> KazakhKey? {
        // 在三行key里找
        if let k = firstRowKeys.first(where: { $0.title == title }) { return k }
        if let k = secondRowKeys.first(where: { $0.title == title }) { return k }
        if let k = thirdRowKeys.first(where: { $0.title == title }) { return k }
        return nil
    }
    
    /// 切换符号与字母键盘（示例）
    private func toggleSymbolKeyboard() {
        // 这里只是简单演示：点击后改变 isShowingSymbols 值，再刷新UI
        // 真实项目中可换成真实的符号布局
        self.isShowingSymbols.toggle()
        // 重新生成 UI 或者切换到另一个视图控制器
        // 此处仅简单替换第一行按钮文字做演示
        if isShowingSymbols {
            // 比如替换第一行全部为数字符号
            // 你也可以在这里替换 secondRow、thirdRow 里的 key
            // 下面是简单演示
            // 先清空 subviews 再重新 layout
            self.view.subviews.forEach { $0.removeFromSuperview() }
            // 在此你可以创建一个“符号键盘布局”，或简单替换一下 text
            setupKeyboard() // 重新加载
        } else {
            // 切回字母
            self.view.subviews.forEach { $0.removeFromSuperview() }
            setupKeyboard()
        }
    }
    
    // MARK: - Override system methods
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents.
    }


}

