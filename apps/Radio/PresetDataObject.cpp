/*
 * Copyright (C) 2016 by Scott Murray <scott.murray@konsulko.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "PresetDataObject.h"

PresetDataObject::PresetDataObject(QObject *parent) : QObject(parent)
{
}

PresetDataObject::PresetDataObject(const QString &title, const quint32 &frequency, const quint32 &band, QObject *parent)
  : QObject(parent), m_title(title), m_frequency(frequency), m_band(band)
{
}

QString PresetDataObject::title() const
{
    return m_title;
}

void PresetDataObject::setTitle(const QString &title)
{
    if (title != m_title) {
        m_title = title;
        emit titleChanged();
    }
}

quint32 PresetDataObject::frequency() const
{
    return m_frequency;
}

void PresetDataObject::setFrequency(const quint32 &frequency) {
    if (frequency != m_frequency) {
        m_frequency = frequency;
        emit frequencyChanged();
    }
}

quint32 PresetDataObject::band() const
{
    return m_band;
}

void PresetDataObject::setBand(const quint32 &band) {
    if (band != m_band) {
        m_band = band;
        emit bandChanged();
    }
}
