data ShapeBaseImageData MyImage {
    state Activate {
        sound = EquipWeaponSound;
        timeoutValue = 0.25;
        transitionOnTimeout = "Ready";
    }
    state Ready {
        sound = DoneSound;
        timeoutValue = 123;
    }
}
