/*
 * Scene.swift
 * FieldScene
 *
 * Created by Callum McColl on 14/8/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import SceneKit

public extension SCNScene {
    
    convenience init?(named name: String, inPackage package: String) {
        self.init(named: name, inAsset: name, inPackage: package)
    }
    
    convenience init?(named name: String, inAsset asset: String, inPackage package: String) {
        let path = Self.bundle(package: package) + "/" + asset + ".scnassets/" + name + ".scn"
        self.init(named: path)
        self.fixResourcePaths(ofNode: self.rootNode, inPackage: package)
    }
    
    private static func bundle(package: String) -> String {
        let expectedBundle = Bundle.main.bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(package + "_" + package + ".bundle", isDirectory: true).appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true).path
        if FileManager.default.fileExists(atPath: expectedBundle) {
            return package + "_" + package + ".bundle/Contents/Resources"
        }
        guard nil != Bundle.allBundles.first(where : {
            return FileManager.default.fileExists(atPath: $0.bundleURL.appendingPathComponent(package + "_" + package + ".bundle", isDirectory: true).path)
        }) else {
            fatalError("Unable to locate bundle in \(Bundle.allBundles.map { $0.bundlePath }), mainBundle: \(Bundle.main.bundlePath)")
        }
        return package + "_" + package + ".bundle"
    }
    
    private static func resourcesURL(ofPackage package: String) -> URL? {
        let expectedBundle = Bundle.main.bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(package + "_" + package + ".bundle", isDirectory: true).appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true)
        if FileManager.default.fileExists(atPath: expectedBundle.path) {
            return expectedBundle
        }
        return nil
    }
    
    private func fixResourcePaths(ofNode node: SCNNode, inPackage package: String) {
        func fixPath(_ path: URL) -> URL? {
            let components = path.pathComponents.drop(while: { $0 != "FieldImages" }).drop(while: { $0 == "FieldImages"})
            if components.isEmpty {
                return nil
            }
            guard let resourcesURL = Self.resourcesURL(ofPackage: package) else {
                return nil
            }
            return URL(fileURLWithPath: components.reduce(resourcesURL.path) { $0 + "/" + $1 }, isDirectory: false)
        }
        func fixContents(_ contents: Any?) -> URL? {
            if let path = contents as? String {
                return fixPath(URL(fileURLWithPath: path, isDirectory: false))
            }
            if let path = contents as? URL {
                return fixPath(path)
            }
            return nil
        }
        node.geometry?.materials.forEach {
            $0.diffuse.contents = fixContents($0.diffuse.contents) ?? $0.diffuse.contents
            $0.normal.contents = fixContents($0.normal.contents) ?? $0.normal.contents
            $0.reflective.contents = fixContents($0.reflective.contents) ?? $0.reflective.contents
            $0.transparent.contents = fixContents($0.transparent.contents) ?? $0.transparent.contents
            $0.ambientOcclusion.contents = fixContents($0.ambientOcclusion.contents) ?? $0.ambientOcclusion.contents
            $0.selfIllumination.contents = fixContents($0.selfIllumination.contents) ?? $0.selfIllumination.contents
            $0.emission.contents = fixContents($0.emission.contents) ?? $0.emission.contents
            $0.multiply.contents = fixContents($0.multiply.contents) ?? $0.multiply.contents
            $0.ambient.contents = fixContents($0.ambient.contents) ?? $0.ambient.contents
            $0.displacement.contents = fixContents($0.displacement.contents) ?? $0.displacement.contents
        }
        node.childNodes.forEach { self.fixResourcePaths(ofNode: $0, inPackage: package) }
    }
    
}