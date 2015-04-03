//sword.ls

datablock AudioProfile leverSwordDrawSound {
   filename: "./swordDraw.wav",
   description: @AudioClosest3d,
   preload: true
}

datablock AudioProfile leverSwordHitSound {
   filename: "./swordHit.wav",
   description: @AudioClosest3d,
   preload: true
}


//effects
datablock Particledatablock leverSwordExplosionParticle {
   dragCoefficient: 2,
   gravityCoefficient: 1.0,
   inheritedVelFactor: 0.2,
   constantAcceleration: 0.0,
   spinRandomMin: -90,
   spinRandomMax: 90,
   lifetimeMS: 500,
   lifetimeVarianceMS: 300,
   textureName: "base/datablock/particles/chunk",
   colors: ["0.7 0.7 0.9 0.9", "0.9 0.9 0.9 0.0"],
   sizes: [0.5, 0.25]
}

datablock ParticleEmitterdatablock leverSwordExplosionEmitter {
   ejectionPeriodMS: 7,
   periodVarianceMS: 0,
   ejectionVelocity: 8,
   velocityVariance: 1.0,
   ejectionOffset  : 0.0,
   thetaMin        : 0,
   thetaMax        : 60,
   phiReferenceVel : 0,
   phiVariance     : 360,
   overrideAdvance: false,
   particles: "leverSwordExplosionParticle",

   uiName: "Sword Hit"
}

datablock Explosiondatablock leverSwordExplosion {
   lifeTimeMS : 500,

   soundProfile : @leverSwordHitSound,

   particleEmitter : @leverSwordExplosionEmitter,
   particleDensity : 10,
   particleRadius : 0.2,

   faceViewer     : true,
   explosionScale : "1 1 1",

   shakeCamera : true,
   camShakeFreq : "20.0 22.0 20.0",
   camShakeAmp : "1.0 1.0 1.0",
   camShakeDuration : 0.5,
   camShakeRadius : 10.0,

   // Dynamic light
   lightStartRadius : 3,
   lightEndRadius : 0,
   lightStartColor : "00.0 0.2 0.6",
   lightEndColor : "0 0 0"
}


//projectile
AddDamageType("LeverSword",   '<bitmap:add-ons/Weapon_LeverSword/CI_sword> %1',    '%2 <bitmap:add-ons/Weapon_LeverSword/CI_sword> %1',0.75,1);

datablock Projectiledatablock leverSwordProjectile {
   directDamage       : 35,
   directDamageType : $DamageType::LeverSword,
   radiusDamageType : $DamageType::LeverSword,
   explosion          : @leverSwordExplosion,
   //particleEmitter     = as;

   muzzleVelocity     : 50,
   velInheritFactor   : 1,

   armingDelay        : 0,
   lifetime           : 100,
   fadeDelay          : 70,
   bounceElasticity   : 0,
   bounceFriction     : 0,
   isBallistic        : false,
   gravityMod: 0.0,

   hasLight   : false,
   lightRadius: 3.0,
   lightColor : "0 0 0.5",

   uiName: "Sword Slice"
}


//////////
// item //
//////////

datablock Itemdatablock leverSwordItem {
    category: "Weapon",  // Mission editor category
    className: "Weapon", // For inventory system

     // Basic Item Properties
    shapeFile: "./sword.dts",
    mass: 1,
    density: 0.2,
    elasticity: 0.2,
    friction: 0.6,
    emap: true,

    //gui stuff
    uiName: "Sword",
    iconName: "./icon_sword",
    doColorShift: true,
    colorShiftColor: "0.471 0.471 0.471 1.000",

     // Dynamic properties defined by the scripts
    image: @leverSwordImage,
    canDrop: true
}

////////////////
//weapon image//
////////////////
datablock ShapeBaseImagedatablock leverSwordImage {
   // Basic Item properties
   shapeFile : "./sword.dts",
   emap : true,

   // Specify mount point & offset for 3rd person, and eye offset
   // for first person rendering.
   mountPoint : 0,
   offset : "0 0 0",

   // When firing from a point offset from the eye, muzzle correction
   // will adjust the muzzle vector to point to the eye LOS point.
   // Since this weapon doesn't actually fire from the muzzle point,
   // we need to turn this off.
   correctMuzzleVector : false,

   eyeOffset : "0.7 1.2 -0.25",

   // Add the WeaponImage namespace as a parent, WeaponImage namespace
   // provides some hooks into the inventory system.
   className : "WeaponImage",

   // Projectile && Ammo.
   item : @leverSwordItem,
   ammo : " ",
   projectile : @leverSwordProjectile,
   projectileType : @Projectile,

   //melee particles shoot from eye node for consistancy
   melee : true,
   doRetraction :false,
   //raise your arm up or not
   armReady : true,

   //casing = " ";
   doColorShift : true,
   colorShiftColor : "0.471 0.471 0.471 1.000",

   state Activate {
       timeoutValue: 0.5,
       transitionOnTimeout: "Ready",
       sound: @leverSwordDrawSound
   },

   state Ready {
       transitionOnTriggerDown: "PreFire",
       stateAllowImageChange: true
   },

   state PreFire {
       script: "onPreFire",
       allowImageChange: false,
       timeoutValue: 0.1,
       transitionOnTimeout: "Fire"
   },

   state Fire {
       transitionOnTimeout: "CheckFire",
       timeoutValue: 0.2,
       fire: true,
       allowImageChange: false,
       sequence: "Fire",
       script: "onFire",
       waitForTimeout: true
   },

   state CheckFire {
       transitionOnTriggerUp: "StopFire",
       transitionOnTriggerDown: "Fire"
   },

   state StopFire {
       transitionOnTimeout: "Ready",
       timeoutValue: 0.2,
       allowImageChange: false,
       waitForTimeout: true,
       sequence: "StopFire",
       script: "onStopFire"
   }
}

fn swordImage::onPreFire(this, obj, slot) {
    obj.playthread(2, @armattack);
}

fn swordImage::onStopFire(this, obj, slot) {
    obj.playthread(2, @root);
}
