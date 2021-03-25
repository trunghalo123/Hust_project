//
//  RegisterViewModel.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import Foundation

class RegisterViewModel: ViewModelProtocol {
        
    struct Input {
        let email: Observable<String> = Observable()
        let password: Observable<String> = Observable()
        let fullName: Observable<String> = Observable()
        let userName: Observable<String> = Observable()
        let registerDidTap: Observable<Any> = Observable()
    }
    
    struct Output {
        let errorsObservable: Observable<String> = Observable()
        let successObservable: Observable<Bool> = Observable()
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(registrationService: RegistrationService) {
        self.input = Input()
        self.output = Output()
    }
    
    
}
