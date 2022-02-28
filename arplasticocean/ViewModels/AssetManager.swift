//
//  AssetManager.swift
//  arplasticocean
//
//  Created by Yasuhito NAGATOMO on 2022/02/27.
//

import Foundation
import RealityKit

/// Manage assets
///
/// * Stage Asset: stored one entity at once. overwritten by new one.
/// * Boat Asset: stored one entity at once. overwritten by new one.
/// * Fish Assets: stored multiple entities. added new ones. never deleted.
/// * Refuse Assets: stored multiple entities. added new ones. never deleted.
class AssetManager {
    private var loadedStageName: String = ""    // load one entity at once
    private var loadedStageEntity: Entity?
    private var loadedStageTexture: String?
    private var loadedBoatName: String = ""     // load one entity at once
    private var loadedBoatEntity: Entity?
    private var loadedNames: [String] = []      // load any entities permanently
    private var loadedEntities: [Entity] = []

    struct MaterialSetting {
        let textureName: String?
        let domeShowing: Bool
        let domeEntityName: String
        let surfaceEntityName: String
        let baseShowing: Bool
        let baseEntityName: String
    }

    func loadStageEntity(name: String, materialSetting: MaterialSetting) -> Entity? {
        if name != loadedStageName {
            if let entity = try? Entity.load(named: name) {
                loadedStageName = name
                loadedStageEntity = entity
            } else {
                loadedStageName = ""
                loadedStageEntity = nil
            }
            loadedStageTexture = nil    // reset every time
        }

        setEntityEnable(materialSetting)

        if materialSetting.textureName != loadedStageTexture {
            loadStageTexture(materialSetting: materialSetting)
            loadedStageTexture = materialSetting.textureName
        }

        return loadedStageEntity
    }

    private func setEntityEnable(_ materialSetting: MaterialSetting) {
        guard let stageEntity = loadedStageEntity  else { return }

        if let domeEntity = stageEntity.findEntity(named: materialSetting.domeEntityName) {
            domeEntity.isEnabled = materialSetting.domeShowing
        }

        if let baseEntity = stageEntity.findEntity(named: materialSetting.baseEntityName) {
            baseEntity.isEnabled = materialSetting.baseShowing
        }
    }

    private func loadStageTexture(materialSetting: MaterialSetting) {
        guard let stageEntity = loadedStageEntity  else { return }
        // Do nothing when textureName is nil. The material will be kept current one.
        guard let textureFileName = materialSetting.textureName else { return }

        var material = UnlitMaterial()
        if let textureResource = try? TextureResource.load(named: textureFileName) {
            material.color.texture = PhysicallyBasedMaterial.Texture(textureResource)

            if let domeEntity = stageEntity.findEntity(named: materialSetting.domeEntityName) {
                if let domeModelEntity = domeEntity as? ModelEntity {
                    domeModelEntity.model?.materials = [ material ]
                }
            }

            if let surfaceEntity = stageEntity.findEntity(named: materialSetting.surfaceEntityName) {
                if let surfaceModelEntity = surfaceEntity as? ModelEntity {
                    surfaceModelEntity.model?.materials = [ material ]
                }
            }

            if let baseEntity = stageEntity.findEntity(named: materialSetting.baseEntityName) {
                if let baseModelEntity = baseEntity as? ModelEntity {
                    baseModelEntity.model?.materials = [ material ]
                }
            }
        } else {
            assertionFailure("Failed to load texture image file. \(textureFileName)")
        }
    }

    func loadBoatEntity(name: String) -> Entity? {
        if name != loadedBoatName {
            if let entity = try? Entity.load(named: name) {
                loadedBoatName = name
                loadedBoatEntity = entity
            } else {
                loadedBoatName = ""
                loadedBoatEntity = nil
            }
        }
        return loadedBoatEntity
    }

    func loadEntity(name: String) -> Entity? {
        var resultEntity: Entity?
        if !loadedNames.contains(name) {
            if let entity = try? Entity.load(named: name) {
                loadedNames.append(name)
                loadedEntities.append(entity)
                resultEntity = entity
            }
        } else {
            let index = loadedNames.firstIndex(of: name)!
            resultEntity = loadedEntities[index]
        }
        return resultEntity
    }
}
